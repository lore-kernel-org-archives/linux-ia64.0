From: Stuart Anderson <anderson@metrolink.com>
Date: Thu, 10 Aug 2000 16:54:16 +0000
Subject: Re: [Linux-ia64] Re: [Xpert] XFree 4.0.1 module loading
Message-Id: <marc-linux-ia64-105590678205312@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 10 Aug 2000, Michael Madore wrote:

> I guess my question now is:  Should the dlopen() loader be able to
> resolve inter-module dependencies?  If not, what is left to be done with
> the elf loader make it functional on IA64?

Support for the ELF64 relocation types. Just like a block of code was added
for Alpha support, the same type of thing will have to be added for IA64.


                                Stuart

Stuart R. Anderson                               anderson@metrolink.com

Metro Link Incorporated                          South Carolina Office
5807 North Andrews Way                           129 Secret Cove Drive
Fort Lauderdale, Florida 33309                   Lexington, SC 29072
voice: 954.660.2500                              voice: 803.951.3630
fax:   954.938.1982                              SkyTel: 800.405.3401
http://www.metrolink.com/


