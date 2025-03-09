#!/bin/bash

TOC_FILE="toc.tmp"

echo "<html><head>"
echo "<link rel=\"stylesheet\" href=\"styles.css\">"
echo "<title>Kubernetes Resources</title></head><body>"
echo "<div class=\"container\">"
echo "<div class=\"sidebar\"><ul>"

> "$TOC_FILE"

kubectl api-resources --verbs=list -o name | while read -r resource; do
    resource_data=$(kubectl get -A "$resource" 2>/dev/null)

    if [[ -z "$resource_data" ]] || echo "$resource_data" | grep -q "No resources found"; then
        continue
    fi

    # Count number of data lines (exclude header)
    total_lines=$(echo "$resource_data" | wc -l)
    data_count=$(( total_lines - 1 ))
    if [ "$data_count" -le 0 ]; then
        continue
    fi

    echo "<li><a href=\"#$resource\">$resource</a> ($data_count)</li>" >> "$TOC_FILE"
done

cat "$TOC_FILE"
rm "$TOC_FILE"

echo "</ul></div><div class=\"content\">"

kubectl api-resources --verbs=list -o name | while read -r resource; do
    resource_data=$(kubectl get -A "$resource" 2>/dev/null)

    if [[ -z "$resource_data" ]] || echo "$resource_data" | grep -q "No resources found"; then
        continue
    fi

    total_lines=$(echo "$resource_data" | wc -l)
    data_count=$(( total_lines - 1 ))
    if [ "$data_count" -le 0 ]; then
        continue
    fi

    echo "<h2 id=\"$resource\"><a href=\"#$resource\">$resource</a> ($data_count)</h2>"

    echo "$resource_data" | awk '
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
    '
done

echo "</div></div></body></html>"
