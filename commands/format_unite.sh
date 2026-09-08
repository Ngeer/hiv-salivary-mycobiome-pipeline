cd /mnt/d/FUNGAL/unite_db
awk '/^>/{
    split($0, a, "|");
    id = a[2];
    tax = a[5];
    gsub("__", ":", tax);
    gsub(";", ",", tax);
    print ">" id ";tax=" tax;
    next
}
{ print }' sh_general_release_dynamic_19.02.2025.fasta > sh_general_release_dynamic_19.02.2025_sintax.fasta
