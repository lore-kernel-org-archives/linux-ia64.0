From: Keith Owens <kaos@sgi.com>
Date: Mon, 16 Dec 2002 04:46:27 +0000
Subject: Re: [Linux-ia64] gas generates incorrect ia64 unwind rlen values
Message-Id: <marc-linux-ia64-105590709805568@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805566@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805566@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 15 Dec 2002 19:38:45 -0800, 
grundler@cup.hp.com (Grant Grundler) wrote:
>On Mon, Dec 16, 2002 at 12:24:03PM +1100, Keith Owens wrote:
>> Using binutils-2.11.90.0.8-12 (old I know, but it is the only version
>> supported on Redhat ia64)
>
>Which RH IA64 are we talking about?

RH 7.2-ia64, Dec 15 2001.

>RH AS 2.1 seems to ship with binutils-2.12.90.0.15-37.
>(not saying it's much better...just different).

As I mentioned in the previous mail, I could not find any mail, bug
reports or changelog entries that mentioned ia64 unwind or rlen being
wrong.  Which makes me think that the bug exists in current binutils,
however I cannot test that at the moment.


