From: Doug Rabson <dfr@nlsystems.com>
Date: Thu, 08 Mar 2001 11:25:54 +0000
Subject: Re: [Linux-ia64] Pointer to function has a bad value
Message-Id: <marc-linux-ia64-105590693005267@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005265@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005265@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 8 Mar 2001, Robboy, David G wrote:

> Is this a known bug or fixed in a later compiler?  Using gcc version
> 2.9-ia64-000216-final, assigning the address of a function to a pointer
> gives the wrong value.  In the following program, the address of twiddle is
> 0x40000000000003f0, but the value of the pointer i is 0x4000000000078300.

For ia64, function pointers are actually pointers to function descriptors.
A function descriptor contains a pointer to the actual function's code and
the value which the 'gp' register should have for that function (this is
part of the ABI support for shared libraries).

A function descriptor looks like this:

	struct ia64_fdesc {
		uint64_t	func;
		uint64_t	gp;
	};

-- 
Doug Rabson				Mail:  dfr@nlsystems.com
					Phone: +44 20 8348 6160





