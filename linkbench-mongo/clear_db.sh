# !/bin/bash
rm /ssdm/collection/*
rm /ssdm/index/*
rm /ssd1/journal/*
rm /ssd1/local/index/*
rm /ssd1/local/collection/*
rm /ssd3/index/*
rm /ssd3/collection/*
rm /hdd1/data/db/*
ln -s /ssd1/journal /hdd1/data/db/
ln -s /ssd1/local /hdd1/data/db/
