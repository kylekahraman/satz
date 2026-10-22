// Normalize English field names into the existing German template records.

#let select-alias(primary, alias, primary-name, alias-name, fallback) = {
  assert(primary == none or alias == none,
    message: "Conflicting fields: provide either `" + primary-name + "` or `" + alias-name + "`, not both.")
  if primary != none { primary } else if alias != none { alias } else { fallback }
}

#let normalize-record(primary, english, aliases, defaults, label) = {
  assert(primary == none or english == none,
    message: "Conflicting " + label + " records: provide either the German record or the English record, not both.")

  let result = (:)
  let supplied = (:)
  if primary != none {
    for (key, value) in primary {
      result.insert(key, value)
      supplied.insert(key, true)
    }
  }
  if english != none {
    for (key, value) in english {
      let target = aliases.at(key, default: key)
      assert(not (target in supplied),
        message: "Conflicting " + label + " fields: provide either `" + target + "` or `" + key + "`, not both.")
      result.insert(target, value)
      supplied.insert(target, true)
    }
  }
  for (key, value) in defaults {
    if not (key in result) { result.insert(key, value) }
  }
  result
}

#let normalize-invoice-items(items) = {
  let result = ()
  for (index, item) in items.enumerate() {
    if type(item) == dictionary {
      for field in ("description", "quantity", "unit-price") {
        assert(field in item,
          message: "Invoice item " + str(index + 1) + " is missing `" + field + "`.")
      }
      result.push((item.at("description"), item.at("quantity"), item.at("unit-price")))
    } else {
      result.push(item)
    }
  }
  result
}
