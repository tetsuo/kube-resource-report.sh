function findColumnStarts(line, starts,   i, len, curr, prev) {
    len = length(line)
    starts[1] = 1
    colCount = 1
    for (i = 2; i <= len; i++) {
        curr = substr(line, i, 1)
        prev = substr(line, i - 1, 1)
        if (prev == " " && curr != " ") {
            colCount++
            starts[colCount] = i
        }
    }
    return colCount
}

function fixHeaderNames(line) {
    gsub("LAST SEEN", "LAST-SEEN", line)
    gsub("ACCESS MODES", "ACCESS-MODES", line)
    gsub("CREATED AT", "CREATED-AT", line)
    return line
}

BEGIN {
    print "<table>";
}

NR == 1 {
    header = fixHeaderNames($0)
    colCount = findColumnStarts(header, starts)
    printf "  <tr>"
    for (i = 1; i <= colCount; i++) {
        if (i < colCount)
            endPos = starts[i + 1] - 1
        else
            endPos = length(header)
        col = substr(header, starts[i], endPos - starts[i] + 1)
        gsub(/^ +| +$/, "", col)
        printf "<th>%s</th>", col
    }
    print "</tr>"
    next
}

{
    printf "  <tr>"
    for (i = 1; i <= colCount; i++) {
        if (i < colCount)
            endPos = starts[i + 1] - 1
        else
            endPos = length($0)
        field = substr($0, starts[i], endPos - starts[i] + 1)
        gsub(/^ +| +$/, "", field)
        printf "<td>%s</td>", field
    }
    print "</tr>"
}

END {
    print "</table><hr/>"
}
