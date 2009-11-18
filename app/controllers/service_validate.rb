=begin
SOURCE:  http://www.jasig.org/cas/protocol

2.5. /serviceValidate [CAS 2.0]

/serviceValidate checks the validity of a service ticket and returns an XML-fragment response. /serviceValidate
MUST also generate and issue proxy-granting tickets when requested. /serviceValidate MUST NOT return a successful
authentication if it receives a proxy ticket. It is RECOMMENDED that if /serviceValidate receives a proxy ticket,
the error message in the XML response SHOULD explain that validation failed because a proxy ticket was passed to
/serviceValidate.

2.5.1. parameters

The following HTTP request parameters MAY be specified to /serviceValidate. They are case sensitive and MUST all
be handled by /serviceValidate.

    * service [REQUIRED] - the identifier of the service for which the ticket was issued, as discussed in Section
      2.2.1.

    * ticket [REQUIRED] - the service ticket issued by /login. Service tickets are described in Section 3.1.

    * pgtUrl [OPTIONAL] - the URL of the proxy callback. Discussed in Section 2.5.4.

    * renew [OPTIONAL] - if this parameter is set, ticket validation will only succeed if the service ticket was
      issued from the presentation of the user's primary credentials. It will fail if the ticket was issued from
      a single sign-on session.

2.5.2. response

/serviceValidate will return an XML-formatted CAS serviceResponse as described in the XML schema in Appendix A.
Below are example responses:

On ticket validation success:
      <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
          <cas:authenticationSuccess>
              <cas:user>username</cas:user>
                  <cas:proxyGrantingTicket>PGTIOU-84678-8a9d...
              </cas:proxyGrantingTicket>
          </cas:authenticationSuccess>
      </cas:serviceResponse>

On ticket validation failure:
      <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
          <cas:authenticationFailure code="INVALID_TICKET">
              Ticket ST-1856339-aA5Yuvrxzpv8Tau1cYQ7 not recognized
          </cas:authenticationFailure>
      </cas:serviceResponse>

2.5.3. error codes

The following values MAY be used as the "code" attribute of authentication failure responses. The following is
the minimum set of error codes that all CAS servers MUST implement. Implementations MAY include others.

    * INVALID_REQUEST - not all of the required request parameters were present

    * INVALID_TICKET - the ticket provided was not valid, or the ticket did not come from an initial login and
      "renew" was set on validation. The body of the <cas:authenticationFailure> block of the XML response SHOULD
      describe the exact details.

    * INVALID_SERVICE - the ticket provided was valid, but the service specified did not match the service
      associated with the ticket. CAS MUST invalidate the ticket and disallow future validation of that same
      ticket.

    * INTERNAL_ERROR - an internal error occurred during ticket validation

For all error codes, it is RECOMMENDED that CAS provide a more detailed message as the body of the
<cas:authenticationFailure> block of the XML response.

2.5.4. proxy callback

If a service wishes to proxy a client's authentication to a back-end service, it must acquire a proxy-granting
ticket. Acquisition of this ticket is handled through a proxy callback URL. This URL will uniquely and securely
identify the back-end service that is proxying the client's authentication. The back-end service can then decide
whether or not to accept the credentials based on the back-end service's identifying callback URL.

The proxy callback mechanism works as follows:

   1. The service that is requesting a proxy-granting ticket specifies upon initial service ticket or proxy
   ticket validation the HTTP request parameter "pgtUrl" to /serviceValidate (or /proxyValidate). This is a
   callback URL of the service to which CAS will connect to verify the service's identity. This URL MUST be
   HTTPS, and CAS MUST verify both that the SSL certificate is valid and that its name matches that of the
   service. If the certificate fails validation, no proxy-granting ticket will be issued, and the CAS service
   response as described in Section 2.5.2 MUST NOT contain a <proxyGrantingTicket> block. At this point, the
   issuance of a proxy-granting ticket is halted, but service ticket validation will continue, returning success
   or failure as appropriate. If certificate validation is successful, issuance of a proxy-granting ticket
   proceeds as in step 2.

   2. CAS uses an HTTP GET request to pass the HTTP request parameters "pgtId" and "pgtIou" to the pgtUrl. These
   entities are discussed in Sections 3.3 and 3.4, respectively.

   3. If the HTTP GET returns an HTTP status code of 200 (OK), CAS MUST respond to the /serviceValidate (or
   /proxyValidate) request with a service response (Section 2.5.2) containing the proxy-granting ticket IOU
   (Section 3.4) within the <cas:proxyGrantingTicket> block. If the HTTP GET returns any other status code,
   excepting HTTP 3xx redirects, CAS MUST respond to the /serviceValidate (or /proxyValidate) request with a
   service response that MUST NOT contain a <cas:proxyGrantingTicket> block. CAS MAY follow any HTTP redirects
   issued by the pgtUrl. However, the identifying callback URL provided upon validation in the <proxy> block MUST
   be the same URL that was initially passed to /serviceValidate (or /proxyValidate) as the "pgtUrl" parameter.

   4. The service, having received a proxy-granting ticket IOU in the CAS response, and both a proxy-granting
   ticket and a proxy-granting ticket IOU from the proxy callback, will use the proxy-granting ticket IOU to
   correlate the proxy-granting ticket with the validation response. The service will then use the proxy-granting
   ticket for the acquisition of proxy tickets as described in Section 2.7.

2.5.5. URL examples of /serviceValidate

Simple validation attempt:
  https://server/cas/serviceValidate?service=http%3A%2F%2Fwww.service.com&...

Ensure service ticket was issued by presentation of primary credentials:
  https://server/cas/serviceValidate?service=http%3A%2F%2Fwww.service.com&... ST-1856339-aA5Yuvrxzpv8Tau1cYQ7&renew=true


Pass in a callback URL for proxying:
  https://server/cas/serviceValidate?service=http%3A%2F%2Fwww.service.com&...

=end

class ServiceValidate < Controller
  map "/serviceValidate"
  def index
    @service = request[:service]
    @ticket = request[:ticket]
    @renew = request[:renew]
    @title = "Service Validate"
  end
end
