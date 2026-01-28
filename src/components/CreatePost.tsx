import { useState, useRef } from "react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Textarea } from "@/components/ui/textarea";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Plus, Loader2, Upload, X } from "lucide-react";
import { supabase } from "@/lib/supabase";
import { useQueryClient } from "@tanstack/react-query";
import { useToast } from "@/hooks/use-toast";

interface CreatePostProps {
  open?: boolean;
  onOpenChange?: (open: boolean) => void;
}

export function CreatePost({ open: controlledOpen, onOpenChange }: CreatePostProps = {}) {
  const [internalOpen, setInternalOpen] = useState(false);
  const open = controlledOpen !== undefined ? controlledOpen : internalOpen;
  const setOpen = onOpenChange || setInternalOpen;
  
  const [caption, setCaption] = useState("");
  const [imageUrl, setImageUrl] = useState("");
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string>("");
  const [petName, setPetName] = useState("");
  const [ownerName, setOwnerName] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isUploading, setIsUploading] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const queryClient = useQueryClient();
  const { toast } = useToast();

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (!file.type.startsWith('image/')) {
      toast({
        title: "Invalid file",
        description: "Please select an image file",
        variant: "destructive",
      });
      return;
    }

    if (file.size > 5 * 1024 * 1024) {
      toast({
        title: "File too large",
        description: "Please select an image smaller than 5MB",
        variant: "destructive",
      });
      return;
    }

    setImageFile(file);
    setImageUrl("");
    
    const reader = new FileReader();
    reader.onloadend = () => {
      setImagePreview(reader.result as string);
    };
    reader.readAsDataURL(file);
  };

  const handleRemoveImage = () => {
    setImageFile(null);
    setImagePreview("");
    setImageUrl("");
    if (fileInputRef.current) {
      fileInputRef.current.value = "";
    }
  };

  const uploadImage = async (file: File): Promise<string> => {
    const fileExt = file.name.split('.').pop();
    const fileName = `${Math.random().toString(36).substring(2)}-${Date.now()}.${fileExt}`;
    const filePath = `posts/${fileName}`;

    const { error: uploadError } = await supabase.storage
      .from('pet-images')
      .upload(filePath, file);

    if (uploadError) throw uploadError;

    const { data } = supabase.storage
      .from('pet-images')
      .getPublicUrl(filePath);

    return data.publicUrl;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if ((!imageFile && !imageUrl) || !caption || !petName || !ownerName) {
      toast({
        title: "Missing fields",
        description: "Please fill in all fields and select an image",
        variant: "destructive",
      });
      return;
    }

    setIsSubmitting(true);

    try {
      let finalImageUrl = imageUrl;

      if (imageFile) {
        setIsUploading(true);
        finalImageUrl = await uploadImage(imageFile);
        setIsUploading(false);
        console.log("Image uploaded successfully:", finalImageUrl);
      }

      console.log("Attempting to insert post with data:", {
        pet_name: petName,
        owner_name: ownerName,
        avatar: finalImageUrl,
        image: finalImageUrl,
        caption: caption,
        likes: 0,
        comments: 0,
        time_ago: "Just now",
      });

      const { data, error } = await supabase.from("feed_posts").insert({
        pet_name: petName,
        owner_name: ownerName,
        avatar: finalImageUrl,
        image: finalImageUrl,
        caption: caption,
        likes: 0,
        comments: 0,
        time_ago: "Just now",
      });

      console.log("Insert result:", { data, error });

      if (error) {
        console.error("Supabase error details:", error);
        throw error;
      }

      toast({
        title: "Post created!",
        description: "Your post has been shared with the community.",
      });

      setCaption("");
      setImageUrl("");
      setImageFile(null);
      setImagePreview("");
      setPetName("");
      setOwnerName("");
      setOpen(false);

      queryClient.invalidateQueries({ queryKey: ["feed"] });
    } catch (error) {
      console.error("Error creating post:", error);
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to create post. Please try again.",
        variant: "destructive",
      });
    } finally {
      setIsSubmitting(false);
      setIsUploading(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogContent className="sm:max-w-[600px]">
        <DialogHeader>
          <DialogTitle>Create a New Post</DialogTitle>
          <DialogDescription>
            Share a moment with your pet community
          </DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="petName">Pet Name</Label>
            <Input
              id="petName"
              placeholder="Max, Luna, etc."
              value={petName}
              onChange={(e) => setPetName(e.target.value)}
              required
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="ownerName">Your Username</Label>
            <Input
              id="ownerName"
              placeholder="@your_username"
              value={ownerName}
              onChange={(e) => setOwnerName(e.target.value)}
              required
            />
          </div>

          <div className="space-y-2">
            <Label>Image</Label>
            
            {!imagePreview && !imageUrl ? (
              <div className="space-y-3">
                <div
                  className="border-2 border-dashed rounded-lg p-8 text-center hover:border-primary/50 transition-colors cursor-pointer"
                  onClick={() => fileInputRef.current?.click()}
                >
                  <Upload className="w-12 h-12 mx-auto mb-4 text-muted-foreground" />
                  <p className="text-sm font-medium mb-1">Click to upload image</p>
                  <p className="text-xs text-muted-foreground">PNG, JPG, GIF up to 5MB</p>
                </div>
                <input
                  ref={fileInputRef}
                  type="file"
                  accept="image/*"
                  className="hidden"
                  onChange={handleFileSelect}
                  aria-label="Upload image file"
                />
                
                <div className="relative">
                  <div className="absolute inset-0 flex items-center">
                    <span className="w-full border-t" />
                  </div>
                  <div className="relative flex justify-center text-xs uppercase">
                    <span className="bg-background px-2 text-muted-foreground">Or paste URL</span>
                  </div>
                </div>
                
                <Input
                  type="url"
                  placeholder="https://example.com/image.jpg"
                  value={imageUrl}
                  onChange={(e) => setImageUrl(e.target.value)}
                />
              </div>
            ) : (
              <div className="relative rounded-lg overflow-hidden border">
                <img
                  src={imagePreview || imageUrl}
                  alt="Preview"
                  className="w-full h-64 object-cover"
                />
                <Button
                  type="button"
                  variant="destructive"
                  size="icon"
                  className="absolute top-2 right-2"
                  onClick={handleRemoveImage}
                >
                  <X className="w-4 h-4" />
                </Button>
              </div>
            )}
          </div>

          <div className="space-y-2">
            <Label htmlFor="caption">Caption</Label>
            <Textarea
              id="caption"
              placeholder="Write a caption for your post..."
              value={caption}
              onChange={(e) => setCaption(e.target.value)}
              rows={4}
              required
            />
          </div>

          <div className="flex justify-end gap-2 pt-4">
            <Button
              type="button"
              variant="outline"
              onClick={() => setOpen(false)}
              disabled={isSubmitting || isUploading}
            >
              Cancel
            </Button>
            <Button type="submit" disabled={isSubmitting || isUploading}>
              {isUploading ? (
                <>
                  <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                  Uploading...
                </>
              ) : isSubmitting ? (
                <>
                  <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                  Posting...
                </>
              ) : (
                "Share Post"
              )}
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
