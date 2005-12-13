From: Keith Owens <kaos@sgi.com>
Date: Tue, 13 Dec 2005 05:13:34 +0000
Subject: Re: sal record header concern
Message-Id: <7859.1134450814@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <439D4ACE.9020701@bull.net>
In-Reply-To: <439D4ACE.9020701@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 12 Dec 2005 20:57:15 -0800, 
"Luck, Tony" <tony.luck@intel.com> wrote:
>> Is your severity "code" set to 02 80?  VALIDATION_BITS Bit 0 = if 1,
>> the OEM_PLATFORM_ID field below contains valid information.
>
>If the 16-bit value is 258, then the two bytes must be "02 01" (since
>258 = 2 + 1*256).  This looks perfectly legal ... the "1" in the next
>byte up (the VALIDATION_BITS) indicating that the OEM_PLATFORM_ID
>contains information.

-ENOTENOUGHCOFFEE.  Every now and again my brain slips into big endian
mode (spending too much time on IBM mainframes) and starts numbering
bits left to right :(

