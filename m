From: Dragan Stancevic <visitor@valinux.com>
Date: Sat, 17 Feb 2001 02:14:45 +0000
Subject: Re: [Linux-ia64] TODO list
Message-Id: <marc-linux-ia64-105590693005167@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005124@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005124@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 16, 2001, Michael Madore <mmadore@turbolinux.com> wrote:
; I copied a 300MB of zeros to a Lion via nfs using an eepro100.  No problems.  This
; is with memory restricted to 1GB.

It won't work with zeros, there has to be the right data in the right places
of the datagram which when multiplexed has to produce a fragment withouth the UDP
header and if by chance the right bits are on in the right places the card will
confuse it for a TCO message which is transperent of the driver.


-- 
No Kernel Hackers were harmed during writing of this email.

                                                -Dragan

