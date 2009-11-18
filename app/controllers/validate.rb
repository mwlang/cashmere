=begin
SOURCE:  http://www.jasig.org/cas/protocol

2.4. /validate [CAS 1.0]

/validate checks the validity of a service ticket./validate is part of the CAS 1.0 protocol and thus does not
handle proxy authentication. CAS MUST respond with a ticket validation failure response when a proxy ticket is
passed to /validate. 2.4.1. parameters

The following HTTP request parameters MAY be specified to /validate. They are case sensitive and MUST all be
handled by /validate.

    * service [REQUIRED] - the identifier of the service for which the ticket was issued, as discussed in Section
      2.2.1.

    * ticket [REQUIRED] - the service ticket issued by /login. Service tickets are described in Section 3.1.

    * renew [OPTIONAL] - if this parameter is set, ticket validation will only succeed if the service ticket was
      issued from the presentation of the user's primary credentials. It will fail if the ticket was issued from a
      single sign-on session.

2.4.2. response

/validate will return one of the following two responses:

On ticket validation success:
    yes<LF>
    username<LF>

On ticket validation failure:
    no<LF>
    <LF>

2.4.3. URL examples of /validate

Simple validation attempt:

https://server/cas/validate?service=http%3A%2F%2Fwww.service.com&ticket=...

Ensure service ticket was issued by presentation of primary credentials:

https://server/cas/validate?service=http%3A%2F%2Fwww.service.com&ticket=...

=end

class Validate < Controller
  layout nil
  
  def index
    @service = request[:service]
    @ticket = request[:ticket]
    @renew = request[:renew]
    @title = "Validate"
  end
end
