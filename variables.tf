variable "dates" {
  description = "List of dates"
  type        = list(string)
  default = ["/20240415/",
    "/20240416/",
    "/20240417/",
    "/20240418/",
    "/20240419/",
    "/20240420/",
    "/20240421/",
    "/20240422/",
    "/20240423/",
    "/20240424/",
    "/20240425/",
  "/20240426/"]
}

variable "subscribers" {
  default = ["yourname1@email.com", "yourname2@email.com"]
}

