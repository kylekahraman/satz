// Normalize English field names into the existing German template records.

#let select-alias(primary, alias, primary-name, alias-name, fallback) = {
  assert(primary == none or alias == none,
    message: "Conflicting fields: provide either `" + primary-name + "` or `" + alias-name + "`, not both.")
  if primary != none { primary } else if alias != none { alias } else { fallback }
}

#let normalize-record(primary, english, aliases, defaults, label) = {
  assert(primary == none or english == none,
    message: "Conflicting " + label + " records: provide either the German record or the English record, not both.")
  assert(primary == none or type(primary) == dictionary,
    message: label + " must be a dictionary.")
  assert(english == none or type(english) == dictionary,
    message: "English " + label + " must be a dictionary.")

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
  assert(type(items) == array, message: "Invoice items must be an array.")
  let result = ()
  for (index, item) in items.enumerate() {
    if type(item) == dictionary {
      for field in ("description", "quantity", "unit-price") {
        assert(field in item,
          message: "Invoice item " + str(index + 1) + " is missing `" + field + "`.")
      }
      let normalized = (item.at("description"), item.at("quantity"), item.at("unit-price"))
      assert(type(normalized.first()) == str or type(normalized.first()) == content,
        message: "Invoice item " + str(index + 1) + " `description` must be a string or content.")
      assert((type(normalized.at(1)) == int or type(normalized.at(1)) == float) and normalized.at(1) > 0,
        message: "Invoice item " + str(index + 1) + " `quantity` must be a positive number.")
      assert((type(normalized.at(2)) == int or type(normalized.at(2)) == float) and normalized.at(2) >= 0,
        message: "Invoice item " + str(index + 1) + " `unit-price` must be a nonnegative number.")
      result.push(normalized)
    } else {
      assert(type(item) == array and item.len() == 3,
        message: "Invoice item " + str(index + 1) + " must be a three-value tuple or a description/quantity/unit-price record.")
      assert(type(item.first()) == str or type(item.first()) == content,
        message: "Invoice item " + str(index + 1) + " description must be a string or content.")
      assert((type(item.at(1)) == int or type(item.at(1)) == float) and item.at(1) > 0,
        message: "Invoice item " + str(index + 1) + " quantity must be a positive number.")
      assert((type(item.at(2)) == int or type(item.at(2)) == float) and item.at(2) >= 0,
        message: "Invoice item " + str(index + 1) + " unit price must be a nonnegative number.")
      result.push(item)
    }
  }
  result
}

#let validate-postal-record(record, label, text-fields, nullable-fields: (), content-fields: ()) = {
  for key in text-fields {
    assert(type(record.at(key)) == str,
      message: label + " field `" + key + "` must be a string.")
  }
  for key in nullable-fields {
    let value = record.at(key)
    assert(value == none or type(value) == str,
      message: label + " field `" + key + "` must be a string or none.")
  }
  for key in content-fields {
    let value = record.at(key)
    assert(value == none or type(value) == content,
      message: label + " field `" + key + "` must be content or none.")
  }
}
