#!/usr/bin/python

########################################################
# Projekt do předmětu PBI
# Zobrazení vyhledaných strukturních elementů
# 31.12.2011
# Autor Ondrej Benes<xbenes00@stud.fit.vutbr.cz>
#
# (c) Copyright 2011 Ondra Beneš. All Rights Reserved. 
########################################################

import pymol
import re

# array of aminoacids
aas = {'A':'ALA', 'R':'ARG', 'N':'ASN', 'D':'ASP', 'C':'CYS', 'Q':'GLN', 'E':'GLU', 'G':'GLY', 'H':'HIS', 'I':'ILE', 'L':'LEU', 'K':'LYS', 'M':'MET', 'F':'PHE', 'P':'PRO', 'S':'SER', 'T':'THR', 'W':'TRP', 'Y':'TYR', 'V':'VAL'}

# visualization function
def visualize(filename):
	
	# clear pymol
	pymol.cmd.reinitialize()
	
	name = ""
	chain = ""
	
	# read file and read first column
	f = open(filename, 'r')
	for i, line in enumerate(f):
	    if i == 0:
	        
	        # parse file name of first line
	        filename = re.split(r' ', line)[0]
	        pieces = re.split(r'_', filename)
	        name = pieces[0]
	        chain = filename[-1]
	        if chain == "_":
	            chain = "A"
	        pymol.cmd.fetch(name)
	        pymol.cmd.color('green')
	        continue
	    line = line[:-1]
	    pieces = re.split(r' ', line)
	    
	    # color elements
	    pymol.cmd.color('red', '/' + name + '//' + chain + '/' + aas[line[0]] + '`' + pieces[1])
