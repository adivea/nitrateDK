#! /bin/sh

# This script will download: Map of Denmark (region based), nitrate layer (points), farm areas (polygons), organic farms (polygons)

# Install gdown for download from drive folder
pip install gdown

# For each link in list of links, download to current folder
for f in https://drive.google.com/uc?id=10dAeREn6ADR8aH9CiCZYbhmQDr4F1fWG https://drive.google.com/uc?id=10pUh8F_OdfFRR61Stb_McTFqUFb8pU3K https://drive.google.com/uc?id=12LTX-QqqcXppnDK09geeoeZHWgeqyWBm https://drive.google.com/uc?id=12W2FtWL9s5_qD9CVREDakm_xt6ZwEOh3 https://drive.google.com/uc?id=135xgO5kRKzrvSBGFwCYuKhDwTsBOZ-Ni https://drive.google.com/uc?id=13t-o8QaEj2rd6XCAl_m0PEavQPZY7P36 https://drive.google.com/uc?id=14mdRrA11lgPNneq9my2UmYPOWrqXCf7R https://drive.google.com/uc?id=15uGZ4Maf4b6ksSrIASmkRG-akgkiH2m8 https://drive.google.com/uc?id=175xUzOH97OpzsTvXYmHzuBSpRKEggZaQ https://drive.google.com/uc?id=17KquodKxqA0_-t0xlp9vfsS9cnXekwyZ https://drive.google.com/uc?id=18-Q_cw2vI8ny6k1iT9nPw7WWpuR7L_hA https://drive.google.com/uc?id=18IFySfAQGrOcugH499-gwNIsHbGTCN4z https://drive.google.com/uc?id=190Y659j0zXde5plfUmVMYvV5jqIurEe0 https://drive.google.com/uc?id=197uRmOScdcQIdab7qPaMlpJ1tXsY6jMu https://drive.google.com/uc?id=19b0D6AD8oYwD-UsavSogWl5uHCx8_vAU https://drive.google.com/uc?id=1AV8cRsCSh9O8CHWojB4hvqBQAfyTdreA https://drive.google.com/uc?id=1AaU_1V91fT6sOOxLXbBDwWZ4sGV9SnFe https://drive.google.com/uc?id=1ApaGhHPUk2y37CjhfrYyGDExIKlS2HcF https://drive.google.com/uc?id=1CQrQUIZj0ICnt68Lym824kf09rNfW1uQ https://drive.google.com/uc?id=1C_6l76ksPKRYlJEkoZ6zNBuhBiO06deX https://drive.google.com/uc?id=1Cd20zSmrV4bv-VHM0O11da6RxjTXa2sn https://drive.google.com/uc?id=1CrhM_wTS9J9lCVnJhTLZPEeUrDsL4xEG https://drive.google.com/uc?id=1DNn5lDy1vNzsXYoI529bPULWziU1BKnv https://drive.google.com/uc?id=1EJYsUoI7cyiD9oE-KY1YbnI1l3cFluL4 https://drive.google.com/uc?id=1F-CEffTqY02tHTqrI7wPtjfnAJpIcYDP https://drive.google.com/uc?id=1GOaMwRDx7s8hA_Pe_UDblHQWZbXg9q3j https://drive.google.com/uc?id=1Gh19ihjPQwkMfz-C2Lp29GsOXayVOnLY https://drive.google.com/uc?id=1IO0VV7wY3_8guJ03CuOleywM-QGaAuZh https://drive.google.com/uc?id=1Ip4k0XhgB9sJHieZ4BMF27jv4R8tey-E https://drive.google.com/uc?id=1JnBa8cZqxDhcmMAziLJhniiC3f59nfJX https://drive.google.com/uc?id=1JwExZwjpuun8nygF6BrvaODuqPdkdEdp https://drive.google.com/uc?id=1KaPqwcPiRErQj8p6IwlX4SUU3QfDKDrU https://drive.google.com/uc?id=1Ln_4KlCfkDUmUxp7dRWYKjJCq3LAcQCf https://drive.google.com/uc?id=1N_1kN3GH_uq7vA8JwK9EG_tp0EPmfS2a https://drive.google.com/uc?id=1OmrPklTDBiAroo7Ry1fvCVwH8gEoPJZG https://drive.google.com/uc?id=1OvJ_DEizw0nSzefEqFAvBPS9RsJrg0Sh https://drive.google.com/uc?id=1P542mAeWwFKAls9PvNoETDjUoQvjoitf https://drive.google.com/uc?id=1PNWm_XS8EQuS5Vv9C2ePRAxtMqclTmdV https://drive.google.com/uc?id=1SX4dPHnuEdPe0yAtG9jmk0jk-ksnU6v3 https://drive.google.com/uc?id=1SxCR6_pePQkA2eT7-L520NH1OKqy2Nc3 https://drive.google.com/uc?id=1TGHvg7Tol68x8f17muaAJ8OqCTmdlt9d https://drive.google.com/uc?id=1TLR5qyE8QTwr_W_jtyK4sFluclfPASUY https://drive.google.com/uc?id=1Ta4aXmvHWfYUFawjVDKgcLjptSUnO8Fe https://drive.google.com/uc?id=1V1gYb2zVpXLs8fmAHm29UZzVtheoDLx3 https://drive.google.com/uc?id=1VDZ5ZickbbOiU2k_Su3BrF5plLk8l340 https://drive.google.com/uc?id=1VyIz69QI9bdiIEIgXO3hxAvAgsH5_cR5 https://drive.google.com/uc?id=1Wj6zAB2Crce46ezWOW54Q6MbmW4gCb9K https://drive.google.com/uc?id=1YgZ0oHyzMuqanaEFKXFjV4E0lmynuq6z https://drive.google.com/uc?id=1Yi5BoxN1WfEaOiJ0L1mOCyWszG2gQfSS https://drive.google.com/uc?id=1Yj-WLgP749UVARRq28Eqlppmk2hIJfT9 https://drive.google.com/uc?id=1ZqX7wWiJSRjSzbv1HDJaBZObQGmFaPFk https://drive.google.com/uc?id=1ZvobiS8iJpALTyy2uBjZ3i__51uBlf7J https://drive.google.com/uc?id=1_RIlgUw7REKBVvoleMKKheQgQ9AxEPRU https://drive.google.com/uc?id=1_u015wBuxhmT3HcSO5FALjvwsIs_BpXX https://drive.google.com/uc?id=1abIohLR0U-t7jQMwEbVA13jrZkA0r5nw https://drive.google.com/uc?id=1apNOESNWve06VXHh1s-dwefCgGbIit8e https://drive.google.com/uc?id=1bIyTOFHkhsN0A3kajeB-twv-ZswAiHm5 https://drive.google.com/uc?id=1bJWyAxjhu5l_VtciKLCgMll8N3EmHgVm https://drive.google.com/uc?id=1cwswU_ctKRnnsezEnR3Ys2WdDpybcDLz https://drive.google.com/uc?id=1fO3ZMlRUNiDwIAQj2IzKKXkeuwG6E-0_ https://drive.google.com/uc?id=1hRfySW8tdMnQQCBKdx21Hn8VgwM5y-Mf https://drive.google.com/uc?id=1hTdNXNkHwc7NN5pkzKFZSt7tfgVChDKD https://drive.google.com/uc?id=1hzoKsXI1HfRWmoT8elDhGEiZAOq5KUnL https://drive.google.com/uc?id=1iFWT6MKbXqb84yZ0qw2dGQWajSW83qvk https://drive.google.com/uc?id=1jc5EPvtkrb-rxFB6LixNuw62F_d_vPT5 https://drive.google.com/uc?id=1jodRiUlacThiP_wFyESUPMiySJo_KCv0 https://drive.google.com/uc?id=1kxaSac_8Mk_uSmeOu45DVoSqmAlg4trR https://drive.google.com/uc?id=1luroKluAwMef-WGU50GNic56k8Iwx1sW https://drive.google.com/uc?id=1mHfAK_nKmAiiS87L4TfbkkQg3wsbUWQp https://drive.google.com/uc?id=1mlngpf8r_ihUEXl6QFi19lIgf_CxdwOM https://drive.google.com/uc?id=1nDuQhO8DoP6yApDA7jZqIrCJ7Ge3IiVz https://drive.google.com/uc?id=1nWUC3HEJAKXhWB9yL7egg0IVeNuSn2K_ https://drive.google.com/uc?id=1pF5lB19nqFu4kmMeS70DRQ1hN-__fAAd https://drive.google.com/uc?id=1q-UUNyP9_SxVZRbOEPH8hMmI-Wh2Axju https://drive.google.com/uc?id=1qvJGiUz3ggTufSv2HN7RVag-C0EZbiuu https://drive.google.com/uc?id=1sYxuYscwLzm06uB8JMg3gDccL1_mUbZp https://drive.google.com/uc?id=1uJJvF01HtT7t0qopqYIig65cZ7UTWJWE https://drive.google.com/uc?id=1uy-1vuXpkI4goJUmpcMSggdXjKLqIM2O https://drive.google.com/uc?id=1xb5Zns_qFrXtjn7NHx2g3duwk6ojFbxQ https://drive.google.com/uc?id=1yG5bUAEYZMsavuZ7WeU8xcV4beQp4-YX https://drive.google.com/uc?id=1zckfir2BCyPEbS_ssZy6gveXX54_GCJk; do gdown $f; done

echo "The required data has been downloaded successfully"
