From: Stuart Anderson <anderson@metrolink.com>
Date: Thu, 10 Aug 2000 18:06:19 +0000
Subject: Re: [Linux-ia64] Re: [Xpert] XFree 4.0.1 module loading
Message-Id: <marc-linux-ia64-105590678205314@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 10 Aug 2000, Bill Nottingham wrote:

> Exactly; the patch we have does that, it just doesn't quite work yet.
> They way the loader is (please, correct me if I'm wrong) is that
> it can load modules in various ways: there's an a.out module
> loader, a dlopen() based loader, and an 'elfloader' that does
> all the elf relocations/symbol resolution itself.

Correct. You can even mix & match between ELF, a.out & COFF on architectures
that support multiple formats. The dlopen() loader does it's bookkeeping
seperately, so you can't mix and match it with the other formats.

> If the X people want me to post what we have, I can do that;

That would be good.

> it's obviously hard to debug the module loader without the
> actual hardware. :)

Hardware does make it easier 8-)


                                Stuart

Stuart R. Anderson                               anderson@metrolink.com

Metro Link Incorporated                          South Carolina Office
5807 North Andrews Way                           129 Secret Cove Drive
Fort Lauderdale, Florida 33309                   Lexington, SC 29072
voice: 954.660.2500                              voice: 803.951.3630
fax:   954.938.1982                              SkyTel: 800.405.3401
http://www.metrolink.com/


