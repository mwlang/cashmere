=begin
SOURCE:  http://www.jasig.org/cas/protocol

2.6. /proxyValidate [CAS 2.0]

/proxyValidate MUST perform the same validation tasks as /serviceValidate and additionally validate proxy tickets.
/proxyValidate MUST be capable of validating both service tickets and proxy tickets.

2.6.1. parameters

/proxyValidate has the same parameter requirements as /serviceValidate. See Section 2.5.1.

2.6.2. response

/proxyValidate will return an XML-formatted CAS serviceResponse as described in the XML schema in Appendix A.
Below are example responses:

On ticket validation success:
      <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
          <cas:authenticationSuccess>
              <cas:user>username</cas:user>
              <cas:proxyGrantingTicket>PGTIOU-84678-8a9d...</cas:proxyGrantingTicket>
              <cas:proxies>
                  <cas:proxy>https://proxy2/pgtUrl</cas:proxy>
                  <cas:proxy>https://proxy1/pgtUrl</cas:proxy>
              </cas:proxies>
          </cas:authenticationSuccess>
      </cas:serviceResponse>

Note that when authentication has proceeded through multiple proxies, the order in which the proxies were
traversed MUST be reflected in the <cas:proxies> block. The most recently-visited proxy MUST be the first proxy
listed, and all the other proxies MUST be shifted down as new proxies are added. In the above example, the service
identified by https://proxy1/pgtUrl was visited first, and that service proxied authentication to the service
identified by https://proxy2/pgtUrl.

On ticket validation failure:
      <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
          <cas:authenticationFailure code="INVALID_TICKET">
              ticket PT-1856376-1HMgO86Z2ZKeByc5XdYD not recognized
          </cas:authenticationFailure>
      </cas:serviceResponse>

2.6.3 URL examples of /proxyValidate

/proxyValidate accepts the same parameters as /serviceValidate. See Section 2.5.5 for use examples, substituting
"proxyValidate" for "serviceValidate".

=end

class ProxyValidate < Controller
  map '/proxyValidate'
  layout nil
  
  def index
    @service = request[:service]
    @ticket = ServiceTicket.find(request[:ticket], @service)
    # @renew = request[:renew]
  end
end
