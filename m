From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 22 Mar 2002 01:07:28 +0000
Subject: Re: [Linux-ia64] Re: Running ia64 2.4.17 kernel on RedHat 7.2 and problems with LoadModule: "scanpci
Message-Id: <marc-linux-ia64-105590701905324@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905319@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905319@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 21 Mar 2002 16:55:58 -0800, 
Piet/Pete Delaney <piet@sgi.com> wrote:
>What about modules that aren't distributed with the kernel but 
>are released as objects (perhaps src) to be linked into the kernel 
>by the customer. For example, something like kdb. Your saying a company
>that distributes kdb like objects that the a sustomer links into the
>kernel must release the src of the objects under the GPL license.

Yes.  Statically linking an object with the kernel requires GPL source,
even if the object is distributed separately from the kernel.  The act
of distributing and statically linking trips the GPL virus.

>So for you to release something like kdb sourceless you would have to
>link it into the kernel as a module and make it useless for early startup.

Yes, but there is no way for kdb to be released without source, it is
far too dependent on the kernel.  I would never contemplate making kdb
binary only.

... IANAL, speaking only for myself, blah, blah, blah


