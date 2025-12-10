<?php

namespace App\Http\Controllers;
use App\Models\Post;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PostController extends Controller
{
    public function index()
    {
        $posts = Post::all();
        $posts->each(function($posts) {
            if($posts -> image) {
                $posts->image_url = url('storage/' . $posts -> image);
            }
        });
        return response()->json($posts);
    }

    public function store(Request $request)
    {
       $request->validate([
           'title' => 'required|string|max:255',
           'author' => 'required|string|max:255',
           'article' => 'required',
           'image' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
       ]);

       $data = $request->only(['title', 'author', 'article']);
       $data['user_id'] = $request->user()->id;

       if ($request->hasFile('image')) {
           $imagePath = $request->file('image')->store('images', 'public');
           $data['image'] = $imagePath;
       }
       $post = Post::create($data);
       if ($post->image) {
           $post->image_url = url('storage/' . $post->image);
       }
       return response()->json($post, 201);
    }

    public function show($id)
    {
        $post = Post::find($id);

        if(!$post) {
            return response()->json(['message' => 'Post not found'], 404);
        }

        if($post -> image) {
            $post->image_url = url('storage/' . $post -> image);
        }
        return response()->json($post);
    }
    
    public function update(Request $request, $id)
    {
        $post = Post::find($id);

        if(!$post) {
            return response()->json(['message' => 'Post not found'], 404);
        }

        $request->validate([
            'title' => 'string|max:255',
            'author' => 'string|max:255',
            'article' => 'nullable',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
        ]);

        $data = $request->only(['title', 'author', 'article']);
        if ($request->hasFile('image')) {
           if ($post->image && Storage::disk('public')->exists($post->image)) {
                Storage::disk('public')->delete($post->image);
           }

            $imagePath = $request->file('image')->store('images', 'public');
            $data['image'] = $imagePath;  
        }

        $post->update($data);
        if ($post->image) {
            $post->image_url = url('storage/' . $post->image);
        }
        return response()->json($post);
    }

    public function destroy($id)
    {
        $post = Post::find($id);
        if(!$post) {
            return response()->json(['message' => 'Post not found'], 404);
        }
        if ($post->image && Storage::disk('public')->exists($post->image)) {
            Storage::disk('public')->delete($post->image);
        }
       $post->delete();
         return response()->json(['message' => 'Post deleted successfully']);
    }
}
