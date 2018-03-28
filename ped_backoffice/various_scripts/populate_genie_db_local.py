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
parser.add_argument('--genie', type=str, nargs=1,
                    help='genie file where to extract informations')
args = parser.parse_args()

genie_file = args.genie[0]


# =============== Connect to MySQL database ===========================#
db = MySQLdb.connect(host="localhost",  # your host, usually localhost
                     user="root",           # your username
                     passwd="Biotech8886",         # your password
                     db="ped_bioinf_portal")        # name of the data base

# you must create a Cursor object. It will let
#  you execute all the queries you need
db.autocommit(True)
cur = db.cursor()

# opening connection to the file and perform queries
with open(genie_file, 'r') as f:
    next(f)
    for line in f:
        line = line.rstrip().split("\t")
        # initialising arguments
        name = line[1]
        target = line[3]
        cancer_type = line[4]
        gender = line[5]
        ethnicity = line[6]
        race = line[7]
        age = line[8]

        cur.execute("INSERT INTO genie(name, target, cancer_type, gender, ethnicity, race, age) VALUES ( \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\", \"%s\");" % (name, target, cancer_type, gender, ethnicity, race, age))

# close connection to the database
db.close()
