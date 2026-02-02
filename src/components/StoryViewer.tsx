import { useState, useEffect, useRef } from 'react';
import { X, ChevronLeft, ChevronRight, Pause, Play, Volume2, VolumeX } from 'lucide-react';
import { Avatar, AvatarImage, AvatarFallback } from '@/components/ui/avatar';
import { useMarkStoryViewed, type StoryGroup } from '@/hooks/useStories';

interface StoryViewerProps {
  storyGroups: StoryGroup[];
  initialGroupIndex: number;
  onClose: () => void;
}

export function StoryViewer({ storyGroups, initialGroupIndex, onClose }: StoryViewerProps) {
  const [currentGroupIndex, setCurrentGroupIndex] = useState(initialGroupIndex);
  const [currentStoryIndex, setCurrentStoryIndex] = useState(0);
  const [isPaused, setIsPaused] = useState(false);
  const [isMuted, setIsMuted] = useState(false);
  const [progress, setProgress] = useState(0);
  const [duration, setDuration] = useState(5000); // Default 5 seconds for images
  const videoRef = useRef<HTMLVideoElement>(null);
  const markViewed = useMarkStoryViewed();

  const currentGroup = storyGroups[currentGroupIndex];
  const currentStory = currentGroup?.stories[currentStoryIndex];

  useEffect(() => {
    if (currentStory && !currentStory.hasViewed) {
      markViewed.mutate(currentStory.id);
    }
  }, [currentStory?.id]);

  useEffect(() => {
    // Reset progress when story changes
    setProgress(0);
    
    // Set duration based on media type
    if (currentStory?.media_type === 'video') {
      // For videos, wait for metadata to load
      if (videoRef.current) {
        const video = videoRef.current;
        const handleLoadedMetadata = () => {
          setDuration(video.duration * 1000); // Convert to milliseconds
        };
        video.addEventListener('loadedmetadata', handleLoadedMetadata);
        return () => video.removeEventListener('loadedmetadata', handleLoadedMetadata);
      }
    } else {
      // For images, use fixed 5 seconds
      setDuration(5000);
    }
  }, [currentStory?.id]);

  useEffect(() => {
    if (isPaused) return;

    const interval = setInterval(() => {
      setProgress((prev) => {
        const next = prev + (100 / (duration / 100));
        if (next >= 100) {
          handleNext();
          return 0;
        }
        return next;
      });
    }, 100);

    return () => clearInterval(interval);
  }, [isPaused, currentGroupIndex, currentStoryIndex, duration]);

  // Control video playback when paused
  useEffect(() => {
    if (videoRef.current) {
      if (isPaused) {
        videoRef.current.pause();
      } else {
        videoRef.current.play();
      }
    }
  }, [isPaused]);

  // Control video mute state
  useEffect(() => {
    if (videoRef.current) {
      videoRef.current.muted = isMuted;
    }
  }, [isMuted]);

  const handleNext = () => {
    const nextStoryIndex = currentStoryIndex + 1;
    
    if (nextStoryIndex < currentGroup.stories.length) {
      setCurrentStoryIndex(nextStoryIndex);
      setProgress(0);
    } else {
      const nextGroupIndex = currentGroupIndex + 1;
      if (nextGroupIndex < storyGroups.length) {
        setCurrentGroupIndex(nextGroupIndex);
        setCurrentStoryIndex(0);
        setProgress(0);
      } else {
        onClose();
      }
    }
  };

  const handlePrev = () => {
    if (currentStoryIndex > 0) {
      setCurrentStoryIndex(currentStoryIndex - 1);
      setProgress(0);
    } else if (currentGroupIndex > 0) {
      const prevGroupIndex = currentGroupIndex - 1;
      const prevGroup = storyGroups[prevGroupIndex];
      setCurrentGroupIndex(prevGroupIndex);
      setCurrentStoryIndex(prevGroup.stories.length - 1);
      setProgress(0);
    }
  };

  const formatTimeAgo = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const hours = Math.floor((now.getTime() - date.getTime()) / (1000 * 60 * 60));
    
    if (hours < 1) return 'Just now';
    if (hours < 24) return `${hours}h ago`;
    return `${Math.floor(hours / 24)}d ago`;
  };

  if (!currentStory) return null;

  return (
    <div className="fixed inset-0 bg-black z-50 flex items-center justify-center">
      {/* Progress bars */}
      <div className="absolute top-0 left-0 right-0 flex gap-1 p-2 z-10">
        {currentGroup.stories.map((_, index) => (
          <div key={index} className="flex-1 h-0.5 bg-white/30 rounded-full overflow-hidden">
            <div
              className="h-full bg-white transition-all duration-100"
              style={{
                width: index < currentStoryIndex ? '100%' : index === currentStoryIndex ? `${progress}%` : '0%',
              }}
            />
          </div>
        ))}
      </div>

      {/* Header */}
      <div className="absolute top-4 left-0 right-0 flex items-center justify-between px-4 z-10">
        <div className="flex items-center gap-3">
          <Avatar className="w-10 h-10 ring-2 ring-white">
            <AvatarImage src={currentGroup.avatar} />
            <AvatarFallback>{currentGroup.username[0]?.toUpperCase()}</AvatarFallback>
          </Avatar>
          <div>
            <p className="text-white font-semibold text-sm">{currentGroup.username}</p>
            <p className="text-white/70 text-xs">{formatTimeAgo(currentStory.created_at)}</p>
          </div>
        </div>
        <div className="flex items-center gap-6">
          <button
            onClick={(e) => {
              e.stopPropagation();
              setIsPaused(!isPaused);
            }}
            className="text-white p-2 hover:bg-white/10 rounded-full transition"
          >
            {isPaused ? <Play className="w-5 h-5" /> : <Pause className="w-5 h-5" />}
          </button>
          {currentStory.media_type === 'video' && (
            <button
              onClick={(e) => {
                e.stopPropagation();
                setIsMuted(!isMuted);
              }}
              className="text-white p-2 hover:bg-white/10 rounded-full transition"
            >
              {isMuted ? <VolumeX className="w-5 h-5" /> : <Volume2 className="w-5 h-5" />}
            </button>
          )}
          <div className="w-12" />
          <button
            onClick={(e) => {
              e.stopPropagation();
              onClose();
            }}
            className="text-white p-2 hover:bg-white/10 rounded-full transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>
      </div>

      {/* Navigation areas */}
      <div className="absolute inset-0 flex">
        <button
          onClick={handlePrev}
          className="flex-1 cursor-pointer group"
          disabled={currentGroupIndex === 0 && currentStoryIndex === 0}
        >
          <div className="h-full flex items-center justify-start pl-4 opacity-0 group-hover:opacity-100 transition">
            <ChevronLeft className="w-10 h-10 text-white" />
          </div>
        </button>
        <button
          onClick={handleNext}
          className="flex-1 cursor-pointer group"
        >
          <div className="h-full flex items-center justify-end pr-4 opacity-0 group-hover:opacity-100 transition">
            <ChevronRight className="w-10 h-10 text-white" />
          </div>
        </button>
      </div>

      {/* Story content */}
      <div className="relative w-full h-full max-w-md mx-auto flex items-center justify-center">
        {currentStory.media_type === 'image' ? (
          <img
            src={currentStory.media_url}
            alt="Story"
            muted={isMuted}
            className="max-w-full max-h-full object-contain"
          />
        ) : (
          <video
            ref={videoRef}
            src={currentStory.media_url}
            className="max-w-full max-h-full object-contain"
            autoPlay
            playsInline
            onEnded={handleNext}
          />
        )}

        {/* Caption */}
        {currentStory.caption && (
          <div className="absolute bottom-24 left-4 right-4">
            <p className="text-white text-sm text-center bg-black/30 backdrop-blur-sm rounded-2xl px-4 py-2">
              {currentStory.caption}
            </p>
          </div>
        )}
      </div>

      {/* View count */}
      <div className="absolute bottom-8 left-1/2 -translate-x-1/2 text-white text-xs flex items-center gap-1 bg-black/30 backdrop-blur-sm rounded-full px-3 py-1">
        <span>👁️</span>
        <span>{currentStory.view_count.toLocaleString()}</span>
      </div>
    </div>
  );
}
