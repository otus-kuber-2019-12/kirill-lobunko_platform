#if working with K/V v1
path "otus/otus-ro/*" {
capabilities = ["read", "list"]
}
path "otus/otus-rw/*" {
capabilities = ["read", "create", "list", "update"]
}

#if working with K/V v2
path "otus/data/otus-ro/*" {
capabilities = ["read", "list"]
}
path "otus/data/otus-rw/*" {
capabilities = ["read", "create", "list", "update"]
}
