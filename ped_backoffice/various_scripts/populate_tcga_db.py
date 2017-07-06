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
    description='Arguments to create target file for BCNTBbp')
parser.add_argument('--tcga', type=str, nargs=1,
                    help='tcga file where to extract informations')
args = parser.parse_args()

tcga_file = args.tcga[0]


# =============== Connect to MySQL database ===========================#
db = MySQLdb.connect(host="localhost",  # your host, usually localhost
                     user="biomart",           # your username
                     passwd="biomart76qmul",         # your password
                     db="ped_bioinf_portal")        # name of the data base

# you must create a Cursor object. It will let
#  you execute all the queries you need
cur = db.cursor()

# opening connection to the file and perform queries
with open(tcga_file, 'r') as f:
    next(f)
    for line in f:
        line = line.rstrip().split("\t")
        # initialising arguments
        name = line[1]
        target = line[2]
        age = line[7]
        years_smoked = line[8]
        alcohol_history = line[9]
        gender = line[10]
        ethnicity = line[11]
        tumor_stage = line[12]
        tnm_staging = line[13]
        histologic_grade = line[14]

        cur.execute("INSERT INTO tcga(name, target, age, years_smoked, alcohol_history, gender, ethnicity, tumor_stage, tnm_staging, histologic_grade) VALUES ( \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\")" % (name, target, age, years_smoked, alcohol_history, gender, ethnicity, tumor_stage, tnm_staging, histologic_grade))

# close connection to the database
db.close()
