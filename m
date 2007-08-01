From: Jes Sorensen <jes@sgi.com>
Date: Wed, 01 Aug 2007 13:33:41 +0000
Subject: Re: ACPI: Uninitialized spinlocks & Unable to dump stack
Message-Id: <yq0zm1bfkga.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0707312246390.14878@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0707312246390.14878@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Kenji" = Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com> writes:

Kenji> Hi,

Kenji> I don't know why no IOSAPIC entries was found on your system.
Kenji> But I think the cause of this stack trace is a bug in the code
Kenji> path of interrupt registering failure. Here is a patch to fix
Kenji> this bug. Could you try that?

Hi Kenji,

The answer to your first comment is simple - we don't have any in the
system :-)

Cheers,
Jes
