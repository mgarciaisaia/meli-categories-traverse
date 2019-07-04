# MeLi Categories Traverse

Try hard to get every item available in a category hierarchy from MercadoLibre.

The code will query MeLi's API for every subcategory available until it gets to
a subcategory with less than 10k items - so we can query for every item there
without hitting the API's limit.

The sample code only prints the ID of the found items - change that to do
whatever you want.

# Usage

```
$ git clone https://github.com/mgarciaisaia/meli-categories-traverse
$ cd meli-categories-traverse
$ bundle
$ ruby meli-categories-traverse.rb
```

To use the app, register a new MercadoLibre Developer application. The script
will ask you for the ID & secret - and give you back an authorization URL.
Follow the link and you should get an authentication code - which you'll also
feed to the script. Then it will do it's work.

You can alternatively set environment variables for the values the script asks.
