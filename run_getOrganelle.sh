### Job name
### Output files
#PBS -e getOrganelle_$id.err
#PBS -o getOrganelle_$id.log
### Only send mail when job is aborted or terminates abnormally
#PBS -m n
### Number of nodes/cores
#PBS -l nodes=1:ppn=40:thinnode
### Minimum memory
#PBS -l mem=180gb
### Requesting time - format is <days>:<hours>:<minutes>:<seconds>
#PBS -l walltime=24:00:00

#########################################################
# loading necessary modules                             #
#########################################################

module load tools miniconda3/4.10.3 lftp/4.9.2 mitoz/2.3

# activate conda environment
conda activate getorganelle

#########################################################
# setting paths/variables                               #
#########################################################

# from commandline: ex. -v "id=GAGA-0001"

wd=/home/people/dinghe/ku_00039/people/dinghe/working_dr/mito_genome_assembly
seed_genome_fasta=/home/people/dinghe/ku_00039/people/dinghe/mitogenomes/ant/ant_seed_mitogenomes.fasta
seed_gene_label_fasta=/home/people/dinghe/ku_00039/people/dinghe/mitogenomes/ant/ant_seed_mitogenomes.label.fasta
read1=/home/people/dinghe/ku_00039/people/dinghe/data/GAGA/stLFR/${id}.1.clean.fq.gz
read2=/home/people/dinghe/ku_00039/people/dinghe/data/GAGA/stLFR/${id}.2.clean.fq.gz
pacbioRead=/home/people/dinghe/ku_00039/people/dinghe/data/GAGA/Raw_genome_reads/fq/${id}.fq.gz
ncbi_read1=/home/people/dinghe/ku_00039/people/dinghe/data/GAGA/Raw_genome_reads/ncbi_sra/fq/${id}_1.fq.gz
nibi_read2=/home/people/dinghe/ku_00039/people/dinghe/data/GAGA/Raw_genome_reads/ncbi_sra/fq/${id}_2.fq.gz
nibi_singleRead=/home/people/dinghe/ku_00039/people/dinghe/data/GAGA/Raw_genome_reads/ncbi_sra/fq/${id}.fq.gz
output_dir=$wd/$id/getOrganelle

#########################################################
# setting paths/variables                               #
#########################################################

mkdir $wd/$id

# MitoGenome assembly from stLFR reads
get_organelle_from_reads.py -t 40 -s $seed_genome_fasta --genes $seed_gene_label_fasta -1 $read1 -2 $read2 -o $output_dir -R 10 -k 21,45,65,85,105 -F animal_mt

# Annotation
conda deactivate
cd $output_dir
awk -v id="$id" 'BEGIN{ RS=">"; i=1 } NR > 1 { print ">"id"_MitoGenome_"i"\n"$2; i++ }' animal_mt*.fasta > ${id}_MitoGenome.fasta
MitoZ.py annotate --genetic_code 5 --clade Arthropoda --outprefix $id --thread_number 1 --fastafile ${id}_MitoGenome.fasta
mv ${id}.result mitoz
rm -rf tmp/

# deposit to ERDA
#lftp -e "set net:connection-limit 16; mkdir -f /GAGA/MitoGenome/${id}; mirror -R $(pwd) /GAGA/MitoGenome/${id}; bye" -p 22 sftp://io.erda.dk

