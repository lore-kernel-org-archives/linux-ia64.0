From: "H. J. Lu" <hjl@lucon.org>
Date: Wed, 05 Nov 2003 18:57:25 +0000
Subject: Re: binutils 2.14.90.7 DV warnings
Message-Id: <marc-linux-ia64-106805896119914@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106805289711668@msgid-missing>
In-Reply-To: <marc-linux-ia64-106805289711668@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 05, 2003 at 09:20:20AM -0800, Jesse Barnes wrote:
> I just tried out the latest versions of gcc (3.3.2) and binutils
> (2.14.90.7) to see if the dependency violation stuff had been fixed
> since I saw that the bintutils changelog mentioned it, but unfortunately
> I still see some warnings (though I _think_ there are fewer than
> before).  I've attached the kernel config I used to build
> linux-2.6.0-test9-mm2, but it should also work with David or Linus's BK
> trees.

There are still a few false warnings on kernel assembly codes. I tried
some of them on Intel IPF assembler and IAS didn't warn them at all
even if DV does exist. I looked at the assembler source. It cann't
be fixed without changing DV check infrastructure. I will look into
them when I find time.


H.J.
