
#!/bin/bash
#usage: ./collec_mutex_results.sh

indir=output_mutex

echo "run compute_ps_mutex.py for all *.mutex files in ${output_mutex}"
echo "collecting ..."
for file in ${indir}/*.mutex; do
	python compute_ps_mutex.py $file
done

echo "collecting results finished."
