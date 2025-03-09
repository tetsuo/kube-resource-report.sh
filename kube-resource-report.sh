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

    echo "$resource_data" | awk -f format_table.awk
done

echo "</div></div></body></html>"
