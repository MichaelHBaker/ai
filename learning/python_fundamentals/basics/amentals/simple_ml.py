"""
Simple Machine Learning from Scratch
Teaching a computer to classify fruits
"""

import random

# ===== STEP 1: THE DATA (Examples we'll learn from) =====
# Format: [weight_grams, color_score(0=red, 1=yellow), label]
# We're showing the computer examples of apples and bananas

training_data = [
    # Apples: heavy, red (0)
    [180, 0.1, "apple"],
    [190, 0.2, "apple"],
    [170, 0.0, "apple"],
    [185, 0.1, "apple"],
    [175, 0.2, "apple"],
    
    # Bananas: light, yellow (1)
    [120, 0.9, "banana"],
    [130, 1.0, "banana"],
    [125, 0.8, "banana"],
    [115, 0.9, "banana"],
    [135, 1.0, "banana"],
]

# ===== STEP 2: THE ALGORITHM (K-Nearest Neighbors) =====
# This is the "learning" part - find similar examples

def distance(fruit1, fruit2):
    """Calculate how similar two fruits are"""
    # Simple distance formula: sqrt((x1-x2)² + (y1-y2)²)
    weight_diff = (fruit1[0] - fruit2[0]) ** 2
    color_diff = (fruit1[1] - fruit2[1]) ** 2
    return (weight_diff + color_diff) ** 0.5

def classify_fruit(unknown_fruit, training_data, k=3):
    """
    Classify a new fruit by looking at its k nearest neighbors
    
    Args:
        unknown_fruit: [weight, color] of fruit we don't know
        training_data: examples we learned from
        k: how many neighbors to check
    """
    # Calculate distance to all known fruits
    distances = []
    for example in training_data:
        known_fruit = [example[0], example[1]]
        label = example[2]
        dist = distance(unknown_fruit, known_fruit)
        distances.append((dist, label))
    
    # Sort by distance (closest first)
    distances.sort()
    
    # Look at k closest neighbors
    neighbors = distances[:k]
    
    # Vote: which label appears most?
    votes = {}
    for _, label in neighbors:
        votes[label] = votes.get(label, 0) + 1
    
    # Return the winner
    winner = max(votes, key=votes.get)
    return winner, neighbors

# ===== STEP 3: TEST IT! =====

print("🤖 Simple Machine Learning Demo")
print("=" * 50)
print("\n📚 Training data (what the computer learned from):")
print("Apples: ~180g, red (color=0)")
print("Bananas: ~125g, yellow (color=1)")

print("\n" + "=" * 50)
print("🧪 Testing on NEW fruits the computer hasn't seen:")
print("=" * 50)

# Test cases
test_fruits = [
    ([185, 0.15], "Should be apple (heavy, red)"),
    ([125, 0.95], "Should be banana (light, yellow)"),
    ([200, 0.05], "Should be apple (very heavy, red)"),
    ([110, 1.0], "Should be banana (light, yellow)"),
]

for fruit, description in test_fruits:
    prediction, neighbors = classify_fruit(fruit, training_data, k=3)
    
    print(f"\n🍎 Mystery fruit: weight={fruit[0]}g, color={fruit[1]}")
    print(f"   {description}")
    print(f"   🤖 Computer says: {prediction.upper()}")
    print(f"   📊 Based on 3 nearest neighbors:")
    for dist, label in neighbors:
        print(f"      - {label} (distance: {dist:.1f})")

print("\n" + "=" * 50)
print("✅ That's machine learning! The computer learned patterns")
print("   from examples, then applied them to new data.")
print("=" * 50)