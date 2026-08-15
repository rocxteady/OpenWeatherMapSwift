# Data Model: Geocoding

All response values are immutable, public, `Decodable`, and `Sendable`. Direct and reverse arrays
remain in service order. Coordinates remain decimal degrees as delivered by OpenWeather.

## GeocodedLocation

Shared by direct and reverse geocoding because both endpoints return the same wire object.

| Property | JSON key | Type | Required |
| --- | --- | --- | --- |
| `name` | `name` | `String` | Yes |
| `localizedNames` | `local_names` | `[String: String]?` | No |
| `latitude` | `lat` | `Double` | Yes |
| `longitude` | `lon` | `Double` | Yes |
| `country` | `country` | `String` | Yes |
| `state` | `state` | `String?` | No |

`localizedNames` preserves every supplied key and value, including unknown language codes,
`ascii`, and `feature_name`. Absence remains `nil`; the client does not synthesize a fallback.

## PostalLocation

| Property | JSON key | Type | Required |
| --- | --- | --- | --- |
| `postalCode` | `zip` | `String` | Yes |
| `name` | `name` | `String` | Yes |
| `latitude` | `lat` | `Double` | Yes |
| `longitude` | `lon` | `Double` | Yes |
| `country` | `country` | `String` | Yes |

## Request values and validation

| Input | Validation | Wire mapping |
| --- | --- | --- |
| Direct place | Not empty after trimming whitespace and newlines | Original value as `q` |
| Direct maximum result count | Absent or `1...5` | `limit` when supplied |
| Postal code | Not empty after trimming whitespace and newlines | First component of `zip` |
| Country code | Not empty after trimming whitespace and newlines | Second component of `zip` |
| Reverse latitude | Finite and within `-90...90` | `lat` |
| Reverse longitude | Finite and within `-180...180` | `lon` |
| Reverse maximum result count | Absent or greater than zero | `limit` when supplied |

Blank checks do not normalize the transmitted text. The ZIP query joins the caller's original
postal and country values with one comma. Country-code semantics remain service validated.

## Relationships and state

Direct and reverse calls each return an ordered `[GeocodedLocation]`; an empty array is a valid
successful result. ZIP returns one `PostalLocation`. Calls have no mutable state transitions,
persistence, or relationships beyond their returned values.
