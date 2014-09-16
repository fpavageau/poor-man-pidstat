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
    cat("Usage: pmfaults.r FILE [FILE...]\n")
    quit()
}

readFaults <- function(index, filename) {
    minorCol <- paste("minor", index, sep = "")
    majorCol <- paste("major", index, sep = "")
    data <- read.table(filename, col.names = c("d", minorCol, majorCol))
    # Transform the timestamp into a real date
    data <- transform(data, d = as.POSIXct(d, origin = as.Date('1970-01-01')))
    return(data)
}

argc <- length(argv)
faults <- list()
maxMinor <- 0
maxMajor <- 0
for (i in 1:argc) {
    currentFaults <- readFaults(i, argv[i])
    maxMinor <- max(c(maxMinor, range(currentFaults[2])[2]))
    maxMajor <- max(c(maxMajor, range(currentFaults[3])[2]))
    faults[[i]] <- currentFaults
    if (i == 1) {
        mergedFaults <- currentFaults
    } else {
        mergedFaults <- merge(mergedFaults, currentFaults, by = "d", all = TRUE)
    }
}

colors <- rainbow(argc)

png("faults.png", width = 1200, height = 1200)
par(mfrow = c(2, 1))

plot(x = mergedFaults$d, y = mergedFaults$minor1, type = "n", xlab = "Time", ylab = "Minor faults", ylim = c(0, maxMinor))
for (i in 1:argc) {
    currentFaults <- faults[[i]]
    name <- names(currentFaults)[2]
    names(currentFaults)[2] <- "value"
    lines(x = currentFaults$d, y = currentFaults$value, type = "o", col = colors[i], lwd = 3, pch = 16, cex = .5)
    names(currentFaults)[2] <- name
}
legend("topright", inset = .05, bty = "n", argv, lwd = c(3, 3), col = colors, cex = 1.5)

plot(x = mergedFaults$d, y = mergedFaults$major1, type = "n", xlab = "Time", ylab = "Major faults", ylim = c(0, maxMajor))
for (i in 1:argc) {
    currentFaults <- faults[[i]]
    name <- names(currentFaults)[3]
    names(currentFaults)[3] <- "value"
    lines(x = currentFaults$d, y = currentFaults$value, type = "o", col = colors[i], lwd = 3, pch = 16, cex = .5)
    names(currentFaults)[3] <- name
}
legend("topright", inset = .05, bty = "n", argv, lwd = c(3, 3), col = colors, cex = 1.5)

dev.off()
