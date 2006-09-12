From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 12 Sep 2006 23:18:54 +0000
Subject: Re: [Fwd: [Fedora-ia64-list] random install panics]
Message-Id: <Pine.LNX.4.64.0609121617520.13616@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <45069E9A.6010207@redhat.com>
In-Reply-To: <45069E9A.6010207@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 12 Sep 2006, Prarit Bhargava wrote:

> Just seeing if anyone here has seen anything similar...

Looks like memory corruption. You need to enable slab debugging and other 
memory debugging options and rerun the tests to get closer to the problem.
