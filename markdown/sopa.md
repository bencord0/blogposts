For a long time, sitting on the side watching the internet play out. The
latest news so far is that SOPA and PIPA have been withdrawn, will probably be
re-written in some form and come back in another democratic cycle or so.

If I was US based, then I would take more personal steps in the war-on-
copyright/fight-against-piracy. Alas, I'm not so I'm going to put up banners,
say the right things and hold double standards on all matters.

I think I should finally weigh in here.

I think I have thought up a method of enforcing copyright that would make the
RIAA, MPAA and other such organisations happy.

It just takes a bit of technical knowledge and some thought.

For the article that finally changed my mind, see [1]

If a car is parked in a parking lot, it isn't laws that stop me from driving
off with it. What's stopping me is the physical security that this collection
of atoms has. Locked doors, metal cages, glass that hurts me if I break it.
Further more, there are ignition sequences tied to owner identities (i.e. the
key), and clearly visible tags that can be verified against a national
database in the cloud.

**Tenant 1/.** Laws are in place for the sole purpose of altering the cost/benefit ratios of the actions we take on a daily basis.

I feel safe to own a car and indeed place it, without supervision, in a public
area because I believe that there are sufficient physical security measures in
place, so that when I next want to use my car, I can. My insurance company
agrees with me. They are assured because I have raised sufficient physical
security barriers to increase the cost of any attempt to use my car without
being me. Hopefully, the cost of stealing my car is greater than the benefit
of having my car. My service and MOT company agrees with me.

If somebody, wrongly or rightly, believes that my car holds untold benefits
that outweigh the costs of owning hammers, chisels, car hacks and jail time,
it is conceivable that they may attempt and succeed in the act of driving off
with my car.

**Tenant 2/.** It is possible to sell the same thing, over and over again, and still make a profit.

In London, the mayor Boris Johnson has developed a scheme colloquially known
as 'Boris Bikes'[2]. This is case where the above problem has been turned on
it's head. By sacrificing personalisation, a scheme can be developed where it
is possible to take a vehicle from a public place and pedalling off with
it[3].

With a small access fee, and a time based usage fee, the system even makes
business sense.

**Tenant 3/.** Personalisation is the means by which ownership is defined.

In the case of Boris Bikes, the personalisation is subtle, but very effective.
There is a link to personal information that we must keep secret. Details of
payment, such as credit card numbers and PIN codes, are mapped to access
codes.

It isn't hard to see that if we didn't hold payment details a tight secret,
then the 'Boris Bike' system would fall apart. I leave this as an exercise for
the reader to figure out how much a bad idea this is.

So, how do we tie all of this into a scheme to protect time Music and Film
industries in the modern digital era?

**Tenant 4/.** Copying broadcast material is easy[4].

If you can hear a music track, take waveform measurements. If you can watch a
film, take light intensity measurements of the pixels.

If the media is encrypted, say a 40-bit DVD level encryption or a 4k-bit
personalised RSA asymmetric key, it doesn't matter. At some point, someone
will want to enjoy the media in unencrypted form. Time to start breaking out
your dusty cathode ray oscilloscopes eh?.

From a distributors point of view, protecting ciphertext is easy. From a
consumer and pirate point of view, ciphertext is an encoded payload. A
consumer has a device to decode and playback the media to plaintext. Pirates
can copy or otherwise transcode the plaintext. I think that any cryptographic
security placed on digital media is futile.

We can learn a few lessons here.

Tenant 1 tells us that we could add laws to rebalance the cost/benefit ratios
of copying to dissuade all but a few percent of the population. This doesn't
really work because a broadcast is aimed to reach as many people as possible,
and a few percent of a very large (positive) number is still a large number,
or at least... a non-negative, non-zero finite.

Tenants 2 and 3 point us in an interesting direction. Add personalisation to
broadcast material. However, tenant 4 tells us we can't apply personalisation
blindly.

It just takes a bit of technical knowledge and some thought.

Encode extremely sensitive and personal information into the plaintext.

An easy statement to make, but is it conceptually feasible to do this? I posit
that it can be done if you want to follow me in a little thought experiment.

Let's start with an example of music.

I must note now that adding personalisation to the plaintext is already being
done. Apple place user ids and into AAC headers. Amazon place user ids into
MP3 ID3 tags. This doesn't stop people from copying the files, it just means
that they are traceable. Of course, there's always the transcoding and
oscilloscope methods to get around this.

Audio is typically encoded as samples of a waveform. We can use techniques
such as Fourier Analysis[5] to encode and compress this wave form in easier to
manage/transmit data points.

A common compression technique is to filter out frequencies that are out of
human hearing ranges, or are have lower amplitudes compared to the remaining
frequencies in the waveform.

If you can take away data, and still leave the sound with enough integrity
that a human doesn't notice, then that's fine. Conversely, you can add data at
low amplitudes without a human noticing too.

Lets say, this data is of an extremely personal nature, perhaps it is that
credit card transaction detail? or maybe just a facebook account login token
maybe sufficient. Nobody would be willing to copy or transcode music if it
means spreading a how-to guide to frape[6].

Unlike ID3 tags, it is feasibly possible to maintain these extra-personal
watermarks across transcoding and other DSP transforms. [7] has a scheme to do
this with images.

Care can be taken in the encoding process such that any attempt to remove the
extra-personal identification data will cause the audible waveform to contort
into an unplayable form. Extra points for an encoder that can cause generic
media to degrade into a Rick Astley hit.

I will also posit that this mechanism has another effect. Music encoded under
such a scheme will never be played aloud in public transport by some
inconsiderate with their headphones on loud. You never know who walks around
with omnidirectional microphones hidden in their backpack.

[1] <http://tacit.livejournal.com/368862.html>  
[2] <http://www.tfl.gov.uk/roadusers/cycling/14808.aspx>  
[3] <http://www.tfl.gov.uk/roadusers/cycling/15025.aspx>  
[4] Copying directed media, like emails and credit card transactions, can be
made into a cryptographically hard problem. This has something to do with the
uniqueness of the data involved.  
[5] <http://mathworld.wolfram.com/FourierTransform.html>  
[6] <http://www.urbandictionary.com/define.php?term=frape>  
[7] <http://www.google.co.uk/search?q=resizing+image+reveals+watermark> reveals 
<http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.132.6623&rep=rep1&type=pdf>