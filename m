From: "H . J . Lu" <hjl@valinux.com>
Date: Tue, 27 Jun 2000 04:19:45 +0000
Subject: Re: [Linux-ia64] Pthreads
Message-Id: <marc-linux-ia64-105590678205180@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205179@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205179@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jun 26, 2000 at 01:03:16PM -0700, Mark Robinson wrote:
> Which version of Pth is the IA-64 compile farm running?
> 

If pthreads is supported on the IA-64 compile farm, it should be the
one in my ia64 glibc tree, which should be very close to glibc 2.1.3
in CVS on sourceware. The only difference is the ia64 support.

-- 
H.J. Lu (hjl@gnu.org)


