# Lab2 - Bulk indexing

## Index using the given data file

+ curl -s -XPOST localhost:9200/_bulk --data-binary @data; echo

# Install plugins

+ plugin -install karmi/elasticsearch-paramedic
+ plugin -install mobz/elasticsearch-head
+ plugin -install polyfractal/elasticsearch-inquisitor

# Check plugin installation

+ Open browser http://localhost:9200/_plugin/head
+ Open browser http://localhost:9200/_plugin/paramedic
+ Open browser http://localhost:9200/_plugin/inquisitor
