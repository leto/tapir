
all:
	parrot -o t/harness.pbc t/harness.pir
	parrot -o lib/Tapir/Parser.pbc lib/Tapir/Parser.pir
	parrot -o lib/Tapir/Stream.pbc lib/Tapir/Stream.pir
	pbc_merge -o tapir.pbc t/harness.pbc lib/Tapir/Parser.pbc lib/Tapir/Stream.pbc
	pbc_to_exe tapir.pbc

clean:
	rm tapir *.pbc t/harness.pbc lib/Tapir/*.pbc

test:
	./tapir t/*.t
