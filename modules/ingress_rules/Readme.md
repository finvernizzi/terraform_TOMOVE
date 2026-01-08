# Ingress rules

According to the ingress-nginx documentation, the first step it follows is to order the paths in descending length, then it transforms these paths into nginx location blocks. nginx follows a first-match policy on these blocks.