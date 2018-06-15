# !/bin/sh
########################################
# There is 3 major phase of the experiment: load data, 1st run, and > 1st run (i.e 2nd run or 3rd run)
# We don't need to call this file for loading data
# Since the 1st run, we call this file to collect output result 
# The 1st run and > 1st runs are very different
# 2nd run, 3rd run, 4th run, ... are similar
########################
#change xmin and xmax value based on sda1 graph out put of build_graph.sh of the 1st run
xmin=0
xmax=9000
#xmax=800
#xmax=4500
#magic=103679103
magic=65794983
echo "extract blk info..."
#./build_graph.sh blk/workloada2_30000000_sda1_40_j 
##from build_graph which collection build graph is the last command, we have wtemp as output
#echo "build_graph_offset_count for blktrace graph"
#./build_graph_offset_count.sh wtemp coll_blk
#the output is coll_blk_fre_W.jpeg and counttemp file
#echo "build_graph_boundary_offset for blktrace graph"
#./build_graph_boundary_offset.sh counttemp coll_blk_bound ${magic}
##the output is coll_blk_bound_boundary_W.jpeg, left-right file

##simple count offset, does not build graph
echo "simple count offset blktrace"
./count_offset.sh wtemp 2 ${magic}
./count_offset.sh wsynctemp 2 ${magic}


echo "extract page type info..."
./build_graph_page_type.sh my_func_track.txt page_type ${xmin} ${xmax}
##for counting number of leaf pages write and plot
#echo "build_graph_offset_count for page_type graph"
#./build_graph_offset_count.sh temp2 coll_leaf 3
#echo "build_graph_boundary_offset for page_type graph"
#./build_graph_boundary_offset.sh counttemp coll_leaf_bound ${magic}

##simple count offset, does not build graph
echo "simple count offset page type"
./count_offset.sh temp2 3 ${magic}

##for counting write size of leaf pages write
#./build_graph_offset_count.sh temp2 coll_leaf_write_size 4

#echo "extract alloc type info..."
#./build_graph_allo_type.sh my_func_track.txt allo_type ${xmin} ${xmax}
##for counting number of page write by best-fit
#./build_graph_offset_count.sh allo_temp3 coll_best_fit 3
#./build_graph_boundary_offset.sh counttemp coll_best_fit_bound ${magic}

##for counting number of write size by best-fit
#./build_graph_offset_count.sh allo_temp3 coll_best_fit_write_size 4 

##for counting rid frequency, require TDN_RID macro enable
#./build_graph_rid_count.sh my_track_rid_snapshot.txt track_rid 3
