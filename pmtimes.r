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
    cat("Usage: pmtimes.r FILE [FILE...]\n")
    quit()
}

readTimes <- function(index, filename) {
    usrCol <- paste("usr", index, sep = "")
    sysCol <- paste("sys", index, sep = "")
    data <- read.table(filename, col.names = c("d", usrCol, sysCol))
    # Transform the timestamp into a real date
    data <- transform(data, d = as.POSIXct(d, origin = as.Date('1970-01-01')))
    return(data)
}

argc <- length(argv)
times <- list()
maxUsr <- 0
maxSys <- 0
for (i in 1:argc) {
    currentTimes <- readTimes(i, argv[i])
    maxUsr <- max(c(maxUsr, range(currentTimes[2])[2]))
    maxSys <- max(c(maxSys, range(currentTimes[3])[2]))
    times[[i]] <- currentTimes
    if (i == 1) {
        mergedTimes <- currentTimes
    } else {
        mergedTimes <- merge(mergedTimes, currentTimes, by = "d", all = TRUE)
    }
}

colors <- rainbow(argc, alpha = 0.5)

png("times.png", width = 1200, height = 1200)
par(mfrow = c(2, 1))

plot(x = mergedTimes$d, y = mergedTimes$usr1, type = "n", xlab = "Time", ylab = "User time", ylim = c(0, maxUsr))
for (i in 1:argc) {
    currentTimes <- times[[i]]
    name <- names(currentTimes)[2]
    names(currentTimes)[2] <- "value"
    lines(x = currentTimes$d, y = currentTimes$value, type = "o", col = colors[i], lwd = 3, pch = 16, cex = .5)
    names(currentTimes)[2] <- name
}
legend("topright", inset = .05, bty = "n", argv, lwd = c(3, 3), col = colors, cex = 1.5)

plot(x = mergedTimes$d, y = mergedTimes$sys1, type = "n", xlab = "Time", ylab = "System time", ylim = c(0, maxSys))
for (i in 1:argc) {
    currentTimes <- times[[i]]
    name <- names(currentTimes)[3]
    names(currentTimes)[3] <- "value"
    lines(x = currentTimes$d, y = currentTimes$value, type = "o", col = colors[i], lwd = 3, pch = 16, cex = .5)
    names(currentTimes)[3] <- name
}
legend("topright", inset = .05, bty = "n", argv, lwd = c(3, 3), col = colors, cex = 1.5)

dev.off()
