From: Grant Grundler <iod00d@hp.com>
Date: Fri, 31 Oct 2003 17:14:20 +0000
Subject: Re: [RFC] Better MCA recovery on IPF
Message-Id: <marc-linux-ia64-106762047208233@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106724227826901@msgid-missing>
In-Reply-To: <marc-linux-ia64-106724227826901@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 31, 2003 at 02:09:12PM +0900, Hidetoshi Seto wrote:
> In the case of platform premising IPF, I think it is
> better to regard the Intel's Chipset as the de facto
> standard.

hmm...given ia64 intel boxes I've played with have no error containment
and softfail on everything, I'm not sure that's a good choice.
Or has enough been published about the chipset to change those
behaviors?

thanks,
grant
