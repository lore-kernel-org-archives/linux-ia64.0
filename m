From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 06 Feb 2001 02:34:57 +0000
Subject: Re: [Linux-ia64] kdb v1.7 for IA64 is available
Message-Id: <marc-linux-ia64-105590693005116@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005109@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005109@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 5 Feb 2001 16:33:27 -0800, 
Michael Madore <mmadore@turbolinux.com> wrote:
>Keith Owens wrote
>> http://oss.sgi.com/projects/kdb/download/ia64/ contains kdb v1.7 for
>> IA64, using the same design as kdb for i386.  This is completely
>> incompatible with HP's version of kdb, use one or the other but not
>> both.
>> 
>
>Is there an advantage to using one of these implementations over the other?

SGI's version of kdb was redesigned some months ago to better handle
SMP, as well as recursion and debugging of kdb itself.  Unless David
Mosberger or Stephane Eranian have any objections[*], SGI will take
over kdb for IA64 again.

[*] Yes David, I _will_ remove the switch_stack change.


