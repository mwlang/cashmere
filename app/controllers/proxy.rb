=begin
SOURCE:  http://www.jasig.org/cas/protocol

2.7. /proxy [CAS 2.0]

/proxy provides proxy tickets to services that have acquired proxy-granting tickets and will be proxying
authentication to back-end services.

2.7.1. parameters

The following HTTP request parameters MUST be specified to /proxy. They are both case-sensitive.

    * pgt [REQUIRED] - the proxy-granting ticket acquired by the service during service ticket or proxy ticket
      validation

    * targetService [REQUIRED] - the service identifier of the back-end service. Note that not all back-end
      services are web services so this service identifier will not always be a URL. However, the service
      identifier specified here MUST match the "service" parameter specified to /proxyValidate upon validation of
      the proxy ticket.

2.7.2. response

/proxy will return an XML-formatted CAS serviceResponse as described in the XML schema in Appendix A. Below are
example responses:

On request success:
      <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
          <cas:proxySuccess>
              <cas:proxyTicket>PT-1856392-b98xZrQN4p90ASrw96c8</cas:proxyTicket>
          </cas:proxySuccess>
      </cas:serviceResponse>

On request failure:
      <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
          <cas:proxyFailure code="INVALID_REQUEST">
              'pgt' and 'targetService' parameters are both required
          </cas:proxyFailure>
      </cas:serviceResponse>

2.7.3. error codes

The following values MAY be used as the "code" attribute of authentication failure responses. The following is the
minimum set of error codes that all CAS servers MUST implement. Implementations MAY include others.

    * INVALID_REQUEST - not all of the required request parameters were present

    * BAD_PGT - the pgt provided was invalid

    * INTERNAL_ERROR - an internal error occurred during ticket validation

For all error codes, it is RECOMMENDED that CAS provide a more detailed message as the body of the
<cas:authenticationFailure> block of the XML response.

2.7.4. URL example of /proxy

Simple proxy request:
  https://server/cas/proxy?targetService=http%3A%2F%2Fwww.service.com&pgt=......


=end

class Proxy < Controller
  def index
    @service = request[:service]
    @ticket = request[:ticket]
    @renew = request[:renew]
    @title = "Proxy"
  end
end
