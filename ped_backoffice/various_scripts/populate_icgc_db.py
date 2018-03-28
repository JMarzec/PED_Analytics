#!/usr/bin/env python

# coder: Stefano Pirro'
# institute: Barts Cancer Institute
# usage:
# description: This script populates the TCGA database starting from a csv file with all the informations

# loading libraries
import argparse
import MySQLdb

# =============== Parsing arguments ===========================#
parser = argparse.ArgumentParser(
    description='Arguments to populate icgc table')
parser.add_argument('--icgc', type=str, nargs=1,
                    help='icgc file where to extract informations')
args = parser.parse_args()

icgc_file = args.icgc[0]


# =============== Connect to MySQL database ===========================#
db = MySQLdb.connect(host="localhost",  # your host, usually localhost
                     user="biomart",           # your username
                     passwd="biomart76qmul",         # your password
                     db="ped_bioinf_portal")        # name of the data base

# you must create a Cursor object. It will let
#  you execute all the queries you need
cur = db.cursor()

# opening connection to the file and perform queries
with open(icgc_file, 'r') as f:
    next(f)
    for line in f:
        line = line.rstrip().split("\t")
        # initialising arguments
        project = line[0]
        cancer_type = line[1]
        expression_array = line[2]
        expression_seq = line[3]
        survival_array = line[4]
        survival_seq = line[5]
        copy_number = line[6]
        mutation = line[7]

        print("INSERT INTO icgc(Project, Cancer_type, Expression_array, Expression_seq, Survival_array, Survival_seq, Copy_number, Mutation) VALUES ( \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\");" % (project, cancer_type, expression_array, expression_seq, survival_array, survival_seq, copy_number, mutation))
        
        cur.execute("INSERT INTO icgc(Project, Cancer_type, Expression_array, Expression_seq, Survival_array, Survival_seq, Copy_number, Mutation) VALUES ( \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\");" % (project, cancer_type, expression_array, expression_seq, survival_array, survival_seq, copy_number, mutation))

# close connection to the database
db.close()
