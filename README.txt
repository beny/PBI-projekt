Spusteni analyzy
================
V ramci projektu byly vytvoreny 2 skripty. Prvni skript analyze.rb ziska a analyzuje molekuly z databaze PDB. Jako jediny parametr ocekava skript soubor s nazvy proteinu z PDB doplnene o retezec. Pro priklad uvedeme protein 1A06 a retezec A

    1A06_A

bude pak v input.txt, ktery predame skriptu v parametru

    ./analyze.rb input.txt

Ke spusteni je nutne mit nainstalove Ruby minimalne verze 1.8.7 a mit v systemu balicek bio (BioRuby). Pro nainstalovani tohoto balicku staci spustit

    gem install bio

Zpracovani a analyza
====================
Prvne si skript zkusi stahnout soubory z PDB pokud existuji. Pote se prohlidne kazdy vlozeny protein a najdou se strukturni elementy zadane dle zadani na retezci zadanem ve vstupnim souboru. Pokud zadny neni zadan (napr 1A06_ nebo 1A06) tak se bere prvni dostupny (nejcasteji to je retezec A). Nakonec se udela prunik vysledku z jednotlivych nalezenych elementu. 

Vystup
======
Vysledek se pak vypise na standardni vystup, ktery lze lehce presmerovat do souboru.

    ./analyze.rb input.txt > output.txt

Visualizace 
===========
Pro visualizaci je prilozen druhy skript a to visualize.py v jazyce Python. Jednoduse vezme prvni zkoumanou molekulu a v PyMol zobrazi spolecne nalezene elementy. Tento skript nacteme v PyMolu a spustime v nem definovanou funkci, kde jediny parametr obsahuje 

    run visualize.py
    visualize("output.txt")