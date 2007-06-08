From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 08 Jun 2007 06:00:41 +0000
Subject: RE: [IA64] Set default page size to 64k
Message-Id: <Pine.LNX.4.64.0706072259190.28618@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 7 Jun 2007, Hans Boehm wrote:

> written data (e.g. for checkpoints or GC), and a small number of writes
> are distributed randomly through the address space (admittedly worst
> case) then 4 times as many bytes appear to be potentially written,
> and hence you may have to copy or scan 4 times as many bytes.
> I think the potential down side in cases like this is substantial,
> though it's probably quite rare.  Fpr software DSM it's probably even
> worse, since you are likely to introduce more false sharing.

On the other hand the transfer size and the locking becomes less. The 
false sharing can be controlled by setting INTERNODE_CACHE_SHIFT 
appropriately.

