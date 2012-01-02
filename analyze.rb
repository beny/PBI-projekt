#!/usr/bin/ruby

########################################################
# Projekt do předmětu PBI
# Vyhledávání strukturních elementů v molekulách
# 31.12.2011
# Autor Ondrej Benes<xbenes00@stud.fit.vutbr.cz>
#
# (c) Copyright 2011 Ondra Beneš. All Rights Reserved. 
########################################################

require "rubygems"
require "bio"
require "net/http"

# debug flag
D = true

def get_name(name)
  name.partition("_")[0]
end

def get_chain(name)
  name.partition("_")[2]
end

# function for finding desired structure elements in array of residues, can return object or aa string
def find_elements(residues, objects = false)
  elements = Array.new
  
  residues.each do |currentRes|
    element = Array.new

    # look around (6 ang) for another related residums
    residues.each do |testRes|
      if not testRes == currentRes
        if currentRes["CA"] and testRes["CA"] and Bio::PDB::Utils.distance(currentRes["CA"].xyz, testRes["CA"].xyz) < 6
          
          if objects
            element << testRes
          else
            # create aa string
            aa = Bio::AminoAcid.one(testRes.resName.capitalize)
            element = "#{element}#{aa}"
          end
        end
      end
    end
    elements << element
  end
  elements
end

# PDB structures variables
pdbProteinsIndentificators = Array.new
pdbProteins = Array.new

results = Array.new

# reading from file just for test
# pdbProteins << File.read("2XZQ.pdb") << File.read("2Y06.pdb") << File.read("2Y07.pdb")

# read input file with PDB indentificators
inputFilename = ARGV[0] || raise("Input file is missing")
inputFile = File.new(inputFilename)
puts "Reading input file #{inputFilename} ..." if D
while(line = inputFile.gets) 
  pdbProteinsIndentificators << line.strip
end

# read all proteins from PDB
puts "Downloading #{pdbProteinsIndentificators.size} PDB files ..." if D
validProteinsName = Array.new
pdbProteinsIndentificators.each do |pdbProtein|
  
  pdbIdentificator = get_name(pdbProtein)
  Net::HTTP.start("www.pdb.org") do |http| 
    resp = http.get("/pdb/files/#{pdbIdentificator}.pdb")
    
    # check if structure exists on PDB
    if resp.kind_of? Net::HTTPOK
      puts "\tOK #{pdbProtein}" if D
      pdbProteins << resp.body
      validProteinsName << pdbProtein
    else
      puts "\tNotFound #{pdbProtein}" if D
    end
  end
end

commonElements = nil

# read and compare elements for each protein
pdbProteins.zip(validProteinsName).each do |protein|
  structure = Bio::PDB.new(protein[0])

  chainName = get_chain(protein[1])
  chain = nil
  # take chosen chain or first if not set
  if chainName.size > 0
    structure.chains.each do |ch|
      chain = ch if ch.id == chainName
    end
  else
    chain = structure.chains.first
  end 

  # find elements
  puts "Looking for elements in protein (#{structure.entry_id})..." if D
  elements = find_elements(chain.residues)
  
  # test print elements
  # puts "List of elements in first protein (#{structure.entry_id})"
  # elements.each do |element|
  #   puts element
  # end
  # puts ""
  
  # print stats
  puts "\t found #{elements.size}\n" if D
  
  # intersect array with results
  commonElements = elements if commonElements == nil
  commonElements &= elements

end

i = 0
# find structures in molecules for numbers
pdbProteins.each do |protein|
  structure = Bio::PDB.new(protein)
  
  results[i] = Array.new
  # TODO fix to take selected chain
  chain = structure.chains.first
  
  elements = find_elements(chain.residues, true)

  elements.each do |e|
    # create aa string for comparing
    aas = ""
    e.each do |aa|
      aas = "#{aas}#{Bio::AminoAcid.one(aa.resName.capitalize)}"
    end
    
    # save position
    if commonElements.include? aas
      # save position
      e.each do |aa|
        results[i] << [Bio::AminoAcid.one(aa.resName.capitalize), aa.resSeq]
      end
       
    end
  end
  
  i += 1
end

# write results on standard output
puts validProteinsName.join(" ")
commonElements.size.times do |i|
  results.each_index do |k|
    print "#{results[k][i][0]} " if k == 0
    print "#{results[k][i][1]} "
  end
  
  print "\n"
end

