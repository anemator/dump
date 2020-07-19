#include <iostream>
#include <string>
#include <type_traits>

// Basically, we want to store a user's contact info, viz. the user's
// name and email (logical) OR postal info. We should fail at compile
// time if Info is not one or both of email/postal info.
//
// One of the biggest benefits of encapsulation is that its easier to
// make illegal states unrepresentable [1][2]. It's such an easy thing to
// do in an ML, I wanted to see what the equivalent would look like in C++
//
// [1] https://blogs.janestreet.com/effective-ml-revisited/
// [2]
// http://fsharpforfunandprofit.com/posts/designing-with-types-making-illegal-states-unrepresentable/

class Stringable {
public:
  virtual std::string ToString() const = 0;
};

class Name final : public Stringable {
public:
  Name(std::string const& first, std::string const& last) {
    first_ = first;
    last_ = last;
  }
  std::string ToString() const override { return first_ + " " + last_; }

private:
  std::string first_;
  std::string last_;
};

class Email final : public Stringable {
private:
  std::string address_;

  Email(std::string const& address) { address_ = address; }
  static bool Valid_(std::string const& address) { return !address.empty(); }

public:
  static Email OfString(std::string const& address) {
    if (!Valid_(address)) {
      throw; // TODO: return an option instead
    }
    return Email(address);
  }
  std::string ToString() const override { return address_; }
};

class Postal final : public Stringable {
private:
  Postal(std::string const& address) { address_ = address; }
  static bool Valid_(std::string const& address) { return !address.empty(); }

public:
  static Postal OfString(std::string const& address) {
    if (!Valid_(address)) {
      throw; // TODO: return an option instead
    }
    return Postal(address);
  }
  std::string ToString() const override { return address_; }

private:
  std::string address_;
};

// Approximation of an algebraic data type (or variant), note the
// static_assert in the Contact class is necessary for the ADT; kinda
// strange to enforce that at the call-site.
class Info : public Stringable {};

class EmailInfo : public Info {
public:
  EmailInfo(Email const& email) : email_(email) {}
  Email GetEmail() const { return email_; }
  std::string ToString() const override { return email_.ToString(); }

private:
  Email email_;
};

class PostalInfo : public Info {
public:
  PostalInfo(Postal const& postal) : postal_(postal) {}
  Postal GetPostal() const { return postal_; }
  std::string ToString() const override { return postal_.ToString(); }

private:
  Postal postal_;
};

class EmailPostalInfo : public EmailInfo, public PostalInfo {
public:
  EmailPostalInfo(Email const& email, Postal const& postal)
      : EmailInfo(email), PostalInfo(postal) {}

  std::string ToString() const override {
    return "Email: " + GetEmail().ToString() +
           "\nPostal: " + GetPostal().ToString();
  }
};

template<class T> class Contact {
public:
  Contact(Name const& name, T const& contactInfo)
      : name_(name), info_(contactInfo) {
    static_assert(std::is_base_of<Info, T>::value,
                  "Contact requires a parameter of type Info");
  }
  Name GetName() const { return name_; }
  T GetInfo() const { return info_; }

private:
  Name name_;
  T info_;
};

Contact<EmailPostalInfo> AddEmail(Contact<PostalInfo> const& contact,
                                  Email const& email) {
  return Contact<EmailPostalInfo>(
      contact.GetName(), EmailPostalInfo(email, contact.GetInfo().GetPostal()));
}

Contact<EmailInfo> UpdateEmail(Contact<EmailInfo> const& contact,
                               Email const& email) {
  return Contact<EmailInfo>(contact.GetName(), EmailInfo(email));
}

Contact<EmailPostalInfo> UpdateEmail(Contact<EmailPostalInfo> const& contact,
                                     Email const& email) {
  return Contact<EmailPostalInfo>(
      contact.GetName(), EmailPostalInfo(email, contact.GetInfo().GetPostal()));
}

Contact<EmailPostalInfo> AddPostal(Contact<EmailInfo> const& contact,
                                   Postal const& postal) {
  return Contact<EmailPostalInfo>(
      contact.GetName(), EmailPostalInfo(contact.GetInfo().GetEmail(), postal));
}

Contact<PostalInfo> UpdatePostal(Contact<PostalInfo> const& contact,
                                 Postal const& postal) {
  return Contact<PostalInfo>(contact.GetName(), PostalInfo(postal));
}

Contact<EmailPostalInfo> UpdatePostal(Contact<EmailPostalInfo> const& contact,
                                      Postal const& postal) {
  return Contact<EmailPostalInfo>(
      contact.GetName(), EmailPostalInfo(contact.GetInfo().GetEmail(), postal));
}

int main() {
  Name name("first", "last");
  Contact<EmailInfo> emailContact(name, Email::OfString("e"));
  Contact<PostalInfo> postalContact(name, Postal::OfString("p"));
  Contact<EmailPostalInfo> emailPostalContact(
      name, EmailPostalInfo(emailContact.GetInfo().GetEmail(),
                            postalContact.GetInfo().GetPostal()));

  auto emailContact1 = UpdateEmail(emailContact, Email::OfString("e1"));
  auto postalContact1 = AddEmail(postalContact, Email::OfString("e2"));
  auto emailPostalContact1 =
      UpdateEmail(emailPostalContact, Email::OfString("e3"));

  auto emailContact2 = AddPostal(emailContact, Postal::OfString("p1"));
  auto postalContact2 = UpdatePostal(postalContact, Postal::OfString("p2"));
  auto emailPostalContact2 =
      UpdatePostal(emailPostalContact, Postal::OfString("p3"));

  return 0;
}

// vim:et:sts=2:sw=2:ts=2:
