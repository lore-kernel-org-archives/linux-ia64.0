From: "David Mosberger-Tang" <David.Mosberger@acm.org>
Date: Thu, 30 Mar 2006 15:53:56 +0000
Subject: Re: [Fedora-ia64-list] kernel 2.6.16-1.2097_FC6 unbootable on Itanium
Message-Id: <ed5aea430603300753u3ae9509cua9993fdf5c995ce5@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB6DD.4020800@sgi.com>
In-Reply-To: <442AB6DD.4020800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 3/30/06, Jack Steiner <steiner@sgi.com> wrote:
> On Thu, Mar 30, 2006 at 08:43:43AM -0700, David Mosberger-Tang wrote:
> > (and at least in theory, it should cause an MCA even on
> > real hardware).
>
> It does, at least on our chipset. If the chipset detects a simultaneous
> UC & C reference, it generates a BUS error. It is surprising how
> quickly this MCA occurs when we break the rules.

That's good.  While MCAs are a pain, it's a lot better than having to
track down data corruption due to (in-)coherency.

 --david
--
Mosberger Consulting LLC, http://www.mosberger-consulting.com/
