From: Evan Felix <evan.felix@pnl.gov>
Date: Tue, 19 Aug 2003 00:12:29 +0000
Subject: Re: ia64 2.6.0-test3 crashes on IOZone
Message-Id: <marc-linux-ia64-106125154127908@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106098668517415@msgid-missing>
In-Reply-To: <marc-linux-ia64-106098668517415@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I tired not to do anything strange,  i place the .config at
http://felix.homeip.net/2.6.config  if you wouldn't mind taking a look.

Evan

On Mon, 2003-08-18 at 16:53, David Mosberger wrote:
> >>>>> On Mon, 18 Aug 2003 14:15:31 -0700, Evan Felix <evan.felix@pnl.gov> said:
> 
>   Evan> I am using an ext3 system, which was made under 2.4.XX  before i
>   Evan> installed the newer kernel.
> 
> OK, so it's not Lustre (otherwise, I'd have suspected a stack
> overflow... ;-)
> 
>   Evan> This test is run in the root filesystem if that makes a
>   Evan> difference.
> 
> Same for me.
> 
> Is there anything unusual in your config (e.g., page size other than
> 16KB)?
> 
> 	--david
