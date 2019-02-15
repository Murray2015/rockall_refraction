#!/bin/bash 

for i in `ls -p | grep "/"`
do 

seaf=`ls ${i}*seafloor*dat`
moho=`ls ${i}*moho*dat`
stem=`echo $seaf | awk -F"/" '{print $2}' | sed 's/.dat//g'`

# Interpolate seafloor, and delete first and last rows (because edge effects)
sample1d $seaf -Ar -Fa `gmtinfo $seaf -T20` | sed '1d; $d'  > ${stem}_seaf_resamp.txt

# Interpolate moho, and delete first and last rows (because edge effects)
sample1d $moho -Ar -Fa `gmtinfo $seaf -T20` | sed '1d; $d' > ${stem}_moho_resamp.txt

# Make x,y file. Remove any dodgy rows. 
paste ${stem}_seaf_resamp.txt ${stem}_moho_resamp.txt | awk '{print $2, $4, $4-$2}' | awk '{if(($1 >= 0) && ($2 != "NaN") && ($1 != "NaN")) print $0}' > ${stem}_seaf_moho_crustalthickness.txt

done 

# Tidy up 
rm *resamp.txt

# Make scatterplot of x,y files 
outfile="Crustal_thickness.ps"
cat *crustalthickness.txt > all_crustalthickness.txt
gmtregress all_crustalthickness.txt -i0,2 -Fxymc -C99 > points_regressed.txt

psxy all_crustalthickness.txt -R0/5/2/35 -JX3i -Sc0.1 -Gblack -Bx1+l"Seafloor depth (km)" -By10+l"Crustal thickness (km)" -P -BSWne -i0,2 -K > $outfile 
makecpt -Crainbow -T1/11/1 > scatter.cpt
counter=1
for i in `ls *moho_crustalthickness.txt`
do
col=`cat scatter.cpt | awk -v counter=$counter '{if(NR==counter+1) print $2}' `
echo $counter $col
psxy $i -G${col} -Sc0.1 -W${col} -J -R -i0,2 -K -O >> $outfile 
((counter++))
done
echo "S 0.1i c 0.1i 283.33-1-1 0.25p 0.3i Funck et al. 2017 RAPIDS-1
S 0.1i c 0.1i 250-1-1 0.25p 0.3i Hauser et al. 1995 n-s RAPIDS
S 0.1i c 0.1i 216.67-1-1 0.25p 0.3i Klingelhofer et al. 2005 line D
S 0.1i c 0.1i 183.33-1-1 0.25p 0.3i Klingelhofer et al. 2005 line E
S 0.1i c 0.1i 150-1-1 0.25p 0.3i Morewood et al. 2005 RAPIDS-31
S 0.1i c 0.1i 116.67-1-1 0.25p 0.3i Morewood et al. 2005 RAPIDS-33
S 0.1i c 0.1i 83.333-1-1 0.25p 0.3i Morewood et al. 2005 RAPIDS-34
S 0.1i c 0.1i 50-1-1 0.25p 0.3i Roberts et al. 1988 profile 1
S 0.1i c 0.1i 16.667-1-1 0.25p 0.3i Roberts et al. 1988 profile 5" > leg.txt
pslegend leg.txt -Dx3.1i/0.5i+w2i -R -J -K -O  >> $outfile 
psxy -R -J points_regressed.txt -L+d+p2,pink -W2,red -i0,2,3 -O >> $outfile 

psconvert -A0.5 $outfile
eog Crustal_thickness.jpg

exit