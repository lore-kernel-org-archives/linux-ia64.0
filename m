From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 22 Nov 2000 02:33:01 +0000
Subject: Re: [Linux-ia64] 001117 toolchain release
Message-Id: <marc-linux-ia64-105590678205764@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205748@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205748@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 21 Nov 2000 18:18:50 -0800, 
Jim Wilson <wilson@cygnus.com> wrote:
>Why 16 bytes?  The sections only have 8 byte data.  (Technically, the unwind
>section has 4 byte data for the 32-bit ABI, but I'm ignoring that for now.)

I did not have the software conventions guide handy at the time.  16
was a "better safe than sorry" value.


