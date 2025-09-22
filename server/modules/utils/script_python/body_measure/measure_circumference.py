import joblib
import numpy as np
from scipy.spatial import ConvexHull

def load_vertices(pkl_path):
    data = joblib.load(pkl_path)
    return data["smpl_vertices"][0]  # shape (6890, 3)

def get_perimeter(points):
    hull = ConvexHull(points)
    perimeter = 0.0
    for i in range(len(hull.vertices)):
        p1 = points[hull.vertices[i]]
        p2 = points[hull.vertices[(i + 1) % len(hull.vertices)]]
        perimeter += np.linalg.norm(p1 - p2)
    return perimeter

def measure_circumference(vertices, height, tol=0.02):
    mask = np.abs(vertices[:, 1] - height) < tol  # y축 기준
    slice_points = vertices[mask][:, [0, 2]]      # (x, z) 평면 투영
    if len(slice_points) < 10:
        return None
    return get_perimeter(slice_points)

def auto_heights(vertices):
    """몸 전체 높이에 따라 상대적 비율로 부위 위치 계산"""
    min_y, max_y = vertices[:,1].min(), vertices[:,1].max()
    total_h = max_y - min_y
    return {
        "허리": min_y + 0.50 * total_h,
        "허벅지": min_y + 0.25 * total_h,
        "팔": min_y + 0.70 * total_h
    }

def compare_circumferences(before_path, after_path):
    v_before = load_vertices(before_path)
    v_after = load_vertices(after_path)

    heights = auto_heights(v_before)  # before 기준으로 잡음

    results = {}
    for part, h in heights.items():
        before = measure_circumference(v_before, h)
        after = measure_circumference(v_after, h)
        results[part] = (before, after)

    print("=== 부위별 둘레 변화 ===")
    for part, (b, a) in results.items():
        if b is None or a is None:
            print(f"{part}: 계산 불가 (데이터 부족)")
        else:
            print(f"{part}: Before {b:.2f}, After {a:.2f}, 변화 {a-b:+.2f}")

if __name__ == "__main__":
    compare_circumferences(
        "output/examples_/pare_results/image1.pkl",
        "output/examples_/pare_results/image2.pkl"
    )
