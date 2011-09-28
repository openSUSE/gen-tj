# Name of TaskJuggler binary, change to 'tj' for TaskJuggler 2.x
TASKJUGGLER = tj3

# Name of Relationtree in FATE
RELATIONTREE = "Name of Relationtree"

# Name of query in Bugzilla
QUERYNAME = "Name of Bugzilla Query"

all: project.tjp resources.tji buglist.tji
	gen-tj $(RELATIONTREE) project
	$(TASKJUGGLER) $<

resources.tji: resources.yml
	gen-resources $< > $@-tmp
	mv -f $@-tmp $@

buglist.tji:
	gen-buglist $(QUERYNAME) > $@-tmp
	mv -f $@-tmp $@

clean:
	rm -f buglist.tji
	rm -f resources.tji
	rm -f *.html
	rm -rf css icons scripts
 
