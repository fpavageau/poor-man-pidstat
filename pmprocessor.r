#!/usr/bin/env r
# Copyright 2014 Frank Pavageau
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if (is.null(argv) | length(argv) == 0) {
    cat("Usage: pmprocessor.r FILE [FILE...]\n")
    quit()
}

readProc <- function(index, filename) {
    procCol <- paste("proc", index, sep = "")
    data <- read.table(filename, col.names = c("d", procCol))
    # Transform the timestamp into a real date
    data <- transform(data, d = as.POSIXct(d, origin = as.Date('1970-01-01')))
    return(data)
}

argc <- length(argv)
procs <- list()
maxProc <- 0
for (i in 1:argc) {
    currentProc <- readProc(i, argv[i])
    maxProc <- max(c(maxProc, range(currentProc[2])[2]))
    procs[[i]] <- currentProc
    if (i == 1) {
        mergedProc <- currentProc
    } else {
        mergedProc <- merge(mergedProc, currentProc, by = "d", all = TRUE)
    }
}

colors <- rainbow(argc, alpha = 0.5)

png("procs.png", width = 1200, height = 1200)
par(mfrow = c(argc, 1))

for (i in 1:argc) {
    plot(x = mergedProc$d, y = mergedProc$proc1, type = "n", xlab = "Time", ylab = "Processor", ylim = c(0, maxProc))
    currentProc <- procs[[i]]
    name <- names(currentProc)[2]
    names(currentProc)[2] <- "value"
    points(x = currentProc$d, y = currentProc$value, type = "o", col = colors[i], lwd = 3, pch = 16, cex = .5)
    names(currentProc)[2] <- name
    legend("topright", inset = .05, bty = "n", argv[i], lwd = c(3, 3), col = colors[i], cex = 1.5)
}

dev.off()
